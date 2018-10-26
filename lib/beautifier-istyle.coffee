{$} = require "atom"


class Beautifier_iStyle
  active: false
  command: null

  config:
    Options:
      type: 'array'
      default: ["--style=kr", "-s4", "--indent-preprocessor", "-P", "--convert-tabs", "--break-blocks"]
      description: 'Comma separated list of iStyle calling argument'

  activate: (state) ->
    @command = atom.commands.add 'atom-text-editor', 'beautifier-istyle:format', => @format()

  deactivate: ->
    @disable()
    @command.dispose()
    @command = null

  format: ->
    if !@active
      activeEditor = atom.workspace.getActiveTextEditor()

      if activeEditor.getPath() != undefined
        grammar = activeEditor.getGrammar()
        if grammar.id == "source.systemverilog" | grammar.id == "source.verilog"
          child_process = require "child_process"
          callback_handler = activeEditor.onDidSave((event) ->
            path = "\"" + event.path  + "\""
            args = ("#{arg}" for arg in atom.config.get('beautifier-istyle.Options'))
            args.push path
            cmd = "iStyle " + args.join(" ")
            console.log('beautifier-istyle:format on ' + grammar.id + ' with ' + cmd)

            child_process.exec(cmd, (error, stdout, stderr) ->
              if error != null
                atom.notifications.addError("Beautifier-iStyle", {
                  detail: "Format fail: fail to invoke iStyle, check whether iStyle can be called in a shell."
                })
                console.log("Format fail: fail to invoke iStyle, check whether iStyle can be called in a shell.")
              console.debug("stdout of iStyle:\n"+stdout)
              console.debug("stderr of iStyle:\n"+stderr)
            )

            callback_handler.dispose()
          )
          activeEditor.save()
        else
          atom.notifications.addWarning("Beautifier-iStyle", {
            detail: 'Not formatted: current file is not a Verilog / System Verilog source (type: ' + grammar.id + ')'
          })
          console.log('not a Verilog/System Verilog source: ' + grammar.id)
      else
        atom.notifications.addError("Beautifier-iStyle", {
          detail: "Format fail: save this file before trying to format it."
        })


  enable: ->
    @active = true

  disable: ->
    @active = false

module.exports = new Beautifier_iStyle
