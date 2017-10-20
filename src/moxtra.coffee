try
    {Robot,Adapter,TextMessage,User,EnterMessage} = require 'hubot'
catch
    prequire = require('parent-require')
    {Robot,Adapter,TextMessage,User,EnterMessage} = prequire 'hubot'

bodyParser = require 'body-parser'
formData = require 'form-data'
fs = require 'fs'
fetch = require 'node-fetch'
crypto = require 'crypto'
URLSafeBase64 = require 'urlsafe-base64'
jwt = require 'jsonwebtoken'
OAuth2 = require './oauth2.js'
cookie = require 'cookie'
require('dotenv').load()

class MoxtraMessage extends TextMessage
    constructor: (@user, @text, @id, @org_id, @event, @message_type) ->
        super @user, @text, @id

class Moxtra extends Adapter
  # key: binder_id   value: access_token from Moxtra
  _moxtraAccessToken = {}

# Constructor method
  constructor: ->
    super
    @robot.logger.info "Constructor"
    endpoint = 'https://api.moxtra.com/v1'
    
    if !process.env.HUBOT_MOXTRA_CLIENTID or !process.env.HUBOT_MOXTRA_SECRET
        @robot.logger.error "Please set up the Environment Variables: HUBOT_MOXTRA_CLIENTID and HUBOT_MOXTRA_SECRET"
        return false
    
    if process.env.HUBOT_MOXTRA_ENV is 'SANDBOX'
        endpoint = "https://apisandbox.moxtra.com/v1"

    if process.env.HUBOT_MOXTRA_ENV is 'DEVELOPMENT'
        endpoint = "https://api.grouphour.com/v1"

    @moxtrabot = {
        client_id: process.env.HUBOT_MOXTRA_CLIENTID,
        client_secret: process.env.HUBOT_MOXTRA_SECRET,
        api_endpoint: endpoint
    }
    
    # @robot.logger.info "moxtrabot:"+JSON.stringify(@moxtrabot)

# Get the "send" message from scripts
  send: (data, strings...) ->
    url = @moxtrabot.api_endpoint + "/" + data.message.id + "/messages"

    body = {}
    body.message = {}
    body.message.richtext = strings[0]

    # @robot.logger.info "********* SEND *************"
    # console.log "POST url: "+url
    # @robot.logger.info "data:"+JSON.stringify(data)+" | body:"+JSON.stringify(body)

    # get the access token
    @getAccessToken @moxtrabot.client_id, data.message.org_id, (err, token) =>
        if token
            # check for buttons
            if data.message.buttons
                body.message.buttons = data.message.buttons
                
            # check for file or audio
            if data.message.options
                @uploadRequest url, body, data.message.options.file_path, data.message.options.audio_path, token.access_token
            else
                @sendRequest url, body, token.access_token
        else
            console.error "Could not retrieve the token for client_id: #{@moxtrabot.client_id} and org_id: #{data.org_id} ERROR: #{err}"

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


# Get the "reply" message from scripts
  reply: (envelope, strings...) ->
    return @send(envelope, "@"+envelope.user.name + " " + strings[0])
  
# Initialize the Adapter
  run: ->
    # self = @
    @robot.logger.info "Hutbot is running with Moxtra Adapter!"
    @robot.logger.info "Once connected to binder I will respond to the name: #{@robot.name}"
    @emit "connected"
    @robot.router.use bodyParser.urlencoded { extended: false }
    @oauth2 = new OAuth2()

    # verification message http response
    @robot.router.get '/hubot/test', (req, res) ->
        res.end 'Hi there! Your Hubot server with Moxtra Adapter is up and running!'
    
    # gateway to receives the post message from Moxtra's Server
    @robot.router.post '/hubot/webhooks', (req, res) =>
        data = req.body
        message_type = data.message_type
        if data == null or message_type == undefined
            res.send 400	
            return

        res.send 200
        @message data

    # gateway to receives GET message from Moxtra's Server (specific for account link)
    @robot.router.get '/hubot/webhooks', (req, res) =>
        # console.log "req: "+req
        if req.query["message_type"] == "account_link"
            # account_link
            account_link_token = req.query['account_link_token']
            # console.log 'Account Link Token: ' + account_link_token + ' client_secret: ' + @moxtrabot.client_secret

            # obtain user_id, binder_id, client_id, & org_id
            try
                decoded = jwt.verify(account_link_token, @moxtrabot.client_secret)
                # console.log JSON.stringify(decoded)  
            catch err
                # log error			  
                console.error 'Unable to verify account_link_token! ' + err
                res.send 412
                return	

            # save the user id and binder_id 
            # in the browser cookie to associate with the token in the callback
            res.cookie 'user_id', decoded.user_id
            res.cookie 'binder_id', decoded.binder_id
            res.cookie 'org_id', decoded.org_id
            res.redirect '/hubot/oauth2/auth'
        else
            res.send 400
    
    # Redirect to the OAuth2 authorization URI
    @robot.router.get '/hubot/oauth2/auth', (req, res, next) =>
        @oauth2.auth(req, res, next)

    # The callback URI for OAuth2 (get the code and token)
    @robot.router.get '/hubot/oauth2/callback', (req, res) =>
        cookies = cookie.parse(req.headers.cookie || '')

        if(!cookies.user_id || !cookies.binder_id || !cookies.org_id)
            console.error "Unable to get user_id, binder_id and org_id from Cookies!"
            res.send 400
        else
            user_id = cookies.user_id
            binder_id = cookies.binder_id
            org_id = cookies.org_id

            #getting the token from the 3rd party api
            @oauth2.callback req, res, (err, token) =>
                
                # create the obj needed in scripts
                data = {}
                data.message_type = "account_link_success"
                data.binder_id = binder_id
                data.org_id = org_id
                data.event = {}
                data.event.binder_id = binder_id
                data.event.user = {}
                data.event.user.id = user_id
                data.event.user.room = binder_id
                data.event.user.token = token
                data.event.comment = {}
                data.event.comment.text = "Account link successed!"

                if err
                    data.message_type = "account_link_error"
                    data.event.comment.text = err

                @message data

# Receives the message from Moxtra's Server and send to scripts
  message: (data) ->
    # @robot.logger.info "********* RECEIVED *************"
    # @robot.logger.info "data: "+JSON.stringify(data)

    text = ""
    if data.event && data.event.comment
        text = data.event.comment.text # or data.event.comment.audio
        if (!text)
            text = data.event.comment.richtext

    user = @robot.brain.userForId(data.event.user.id)
    user.name = data.event.user.name
    user.room = data.event.binder_id
    msg = new MoxtraMessage(user, text, data.binder_id, data.org_id, data.event, data.message_type)

    @robot.receive msg

# Get Access token to send the message back to Moxtra's Server
  getAccessToken: (client_id, org_id, callback) ->
    # console.log "**** GETTING TOKEN ****"
    timestamp = (new Date).getTime()
    token = _moxtraAccessToken[ org_id ]
    if token
        if timestamp < token.expired_time
            # console.log "Using EXISTING token. "+token.access_token
            callback(null, token)
            return
    
    buf = client_id + org_id + timestamp
    sig = crypto.createHmac('sha256', new Buffer(@moxtrabot.client_secret)).update(buf).digest()
    signature = URLSafeBase64.encode sig
    url = @moxtrabot.api_endpoint + '/apps/token?client_id=' + client_id + '&org_id=' + org_id + '&timestamp=' + timestamp + '&signature=' + signature
    
    @robot.http(url)
      .get() (err, response, body) ->
        if response.statusCode isnt 200
            callback "Token request didn't come back HTTP 200 :(", null
        else if err
            console.error err
            callback err, null
        else if body
            org_token = JSON.parse(body)
            org_token.expired_time = timestamp + (parseInt(org_token.expires_in) * 1000)
            _moxtraAccessToken[ org_id ] = org_token
            # console.log "Got NEW access_token! "+ org_token.access_token + " expired_time: " + org_token.expired_time
            callback null, org_token


  
# Get the Moxtra's Bot name
  getBotName: (access_token, callback) ->
    url = @moxtrabot.api_endpoint + "/me?access_token=" + access_token
    @robot.http(url).get() (err, response, body) ->
        console.log "getBotName: "+body
        if response.statusCode isnt 200
            callback "Bot name request didn't come back HTTP 200 :(", null
        else if err
            console.error err
            callback err, null
        else if body
            obj = JSON.parse(body)
            callback null, obj.data.name


# Display a more friendly error message
#   @robot.router.use (err, req, res, next) ->
#     code = err.code || 500
#     message = err.message
#     res.writeHead code, message, {'content-type' : 'application/json'}
#     res.end err.toString()

exports.use = (robot) ->
  new Moxtra robot