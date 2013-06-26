Prompt = require './prompt'
{createSite, Document} = require 'telepath'
{createPeer, connectDocument} = require './session-utils'

startSession = ->
  peer = createPeer()
  peer.on 'connection', (connection) ->
    connection.on 'open', ->
      console.log 'sending document'
      windowState = atom.getWindowState()
      connection.send(windowState.serialize())
      connectDocument(windowState, connection)
  peer.id

module.exports =
  activate: ->
    sessionId = null

    rootView.command 'collaboration:copy-session-id', ->
      pasteboard.write(sessionId) if sessionId

    rootView.command 'collaboration:start-session', ->
      if sessionId = startSession()
        pasteboard.write(sessionId)

    rootView.command 'collaboration:join-session', ->
      new Prompt (id) ->
        windowSettings =
          bootstrapScript: require.resolve('collaboration/lib/bootstrap')
          resourcePath: window.resourcePath
          sessionId: id
        atom.openWindow(windowSettings)