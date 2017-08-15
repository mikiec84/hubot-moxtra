try
    {Robot,Adapter,TextMessage,User,EnterMessage} = require 'hubot'
catch
    prequire = require('parent-require')
    {Robot,Adapter,TextMessage,User,EnterMessage} = prequire 'hubot'

bodyParser = require 'body-parser'
formData = require 'form-data'
fs = require 'fs'
fetch = require 'node-fetch'

class MoxtraMessage extends TextMessage
    constructor: (@user, @text, @id, @access_token, @event, @message_type) ->
        super @user, @text, @id

class Moxtra extends Adapter

  constructor: ->
    super
    @robot.logger.info "Constructor"
    endpoint = 'https://api.moxtra.com/v1'
    
    if !process.env.HUBOT_MOXTRA_TOKEN or !process.env.HUBOT_MOXTRA_SECRET
        @robot.logger.error "Please set up the Environment Variables: HUBOT_MOXTRA_TOKEN and HUBOT_MOXTRA_SECRET"
        return false
    
    if process.env.HUBOT_MOXTRA_ENV is 'SANDBOX'
        endpoint = "https://apisandbox.moxtra.com/v1"

    @moxtrabot = {
        verify_token: process.env.HUBOT_MOXTRA_TOKEN,
        client_secret: process.env.HUBOT_MOXTRA_SECRET,
        api_endpoint: endpoint
    }

    @robot.logger.info "moxtrabot:"+JSON.stringify(@moxtrabot)

  send: (data, strings...) ->
    @robot.logger.info "********* Send *************"
    url = @moxtrabot.api_endpoint + "/messages"

    body = {}
    body.message = {}
    body.message.richtext = strings[0]

    @robot.logger.info "data:"+JSON.stringify(data)+" | body:"+JSON.stringify(body)

    # check for buttons
    if data.message.buttons
        body.message.buttons = data.message.buttons
         
    # check for file or audio
    if data.message.options
        @uploadRequest url, body, data.message.options.file_path, data.message.options.audio_path, data.message.access_token
    else
        @sendRequest url, body, data.message.access_token

  sendRequest: (url, body, access_token) ->
    @robot.http(url)
      .header('Content-Type', 'application/json')
      .header('Authorization', 'Bearer ' + access_token)
      .post(JSON.stringify(body)) (err, res, obj) ->
        console.log "RETURN:" + obj

  uploadRequest: (url, body, file, audio, access_token) ->
    form = new formData()

    if body
        form.append 'payload', JSON.stringify(body)
    if file
        form.append 'file', fs.createReadStream(file)
    if audio
        form.append 'audio', fs.createReadStream(audio)
    
    fetch(url, {method: 'POST', headers: {'Accept': 'multipart/form-data','Authorization': 'Bearer ' + access_token}, body: form})
      .then(res: => 
        res.json()
        )
      .then(res: => 
        if (res.error)
            console.log(res.error)
        return res
        )
      .catch(err: => 
        console.log 'Error uploading file: ${err}'
      )

  reply: (envelope, strings...) ->
    @robot.logger.info "********* Reply *************"
    return @send(envelope, "@"+envelope.user.name + " " + strings[0])


  run: ->
    # self = @
    @robot.logger.info "Hutbot is running with Moxtra Adapter!"
    @robot.logger.info "Once connected to binder I will respond to the name: #{@robot.name}"
    @emit "connected"
    @robot.router.use bodyParser.urlencoded { extended: false }

    # test http response
    @robot.router.get '/hubot/test', (req, res) ->
        res.end 'Hi there! Your Hubot server with Moxtra Adapter is up and running!'

    # bot verification
    verify_token = @moxtrabot.verify_token
    client_secret = @moxtrabot.client_secret
    @robot.router.get '/hubot/webhooks', (req, res) ->
        console.log "REQUEST:"+JSON.stringify(req.query)

        if req.query['message_type'] is 'bot_verify' and req.query['verify_token'] is verify_token
            console.log 'Verification Succeed!'
            if req.query['callback']
                res.status(200).jsonp(req.query['bot_challenge'])
            else
                res.status(200).send(req.query['bot_challenge'])
        else 
            if req.query['message_type'] is 'account_link'
                account_link_token = req.query['account_link_token']
                console.log 'Account Link Token: ' + account_link_token

                try
                    decoded = jwt.verify(account_link_token, client_secret)
                    @emit('account_link', req, res, decoded);
                catch error
                    console.error 'Unable to verify account_link_token!'
                    res.send(412)
            else
                console.error 'Verification Failed!'
                if req.query['callback']
                    res.status(200).jsonp('Error-Verification')
                else 
                    res.send(403)

			
    
    # gets the message from Moxtra
    @robot.router.post '/hubot/webhooks', (req, res) =>
        data = req.body
        message_type = data.message_type
        if data == null or message_type == undefined
            res.send 400	
            return

        res.send 200
        @message data


  message: (data) ->
    console.log "MESSAGE RECEIVED FROM MOXTRA SERVER:"+JSON.stringify(data)
    text = ""
    if data.event.comment
        text = data.event.comment.text
        if (!text)
            text = data.event.comment.richtext

    user = @robot.brain.userForId(data.event.user.id)
    user.name = data.event.user.name
    user.room = data.event.binder_id
    msg = new MoxtraMessage(user, text, data.binder_id, data.access_token, data.event, data.message_type)

    @robot.receive msg
    
  # Display a more friendly error message
#   @robot.router.use (err, req, res, next) ->
#     code = err.code || 500
#     message = err.message
#     res.writeHead code, message, {'content-type' : 'application/json'}
#     res.end err.toString()

exports.use = (robot) ->
  new Moxtra robot

