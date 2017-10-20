'use strict'

var simpleOauthModule = require('simple-oauth2');
require('dotenv').load();

function OAuth2() {
  const client_id = process.env.HUBOT_OAUTH2_CLIENT_ID;
  const client_secret = process.env.HUBOT_OAUTH2_CLIENT_SECRET;
  const oauth2_endpoint = process.env.HUBOT_OAUTH2_ENDPOINT;
  const oauth2_auth_path = process.env.HUBOT_OAUTH2_AUTH_PATH;
  const oauth2_token_path = process.env.HUBOT_OAUTH2_TOKEN_PATH;
  const oauth2_redirect_uri = process.env.HUBOT_OAUTH2_REDIRECT_URI;
  
  if (!client_id && !client_secret && !oauth2_endpoint && !oauth2_auth_path && !oauth2_token_path
     && !oauth2_redirect_uri) {
    throw new Error('Require a complete configuration for OAuth2. Please check the file config.js at the root of the app.');
  }  
  
  // key track of redirect_uri
  this.oauth2_redirect_uri = oauth2_redirect_uri;
  
	this.oauth2 = simpleOauthModule.create({
	  client: {
	    id: client_id,
	    secret: client_secret
	  },
	  auth: {
	    tokenHost: oauth2_endpoint,
	    tokenPath: oauth2_token_path,
	    authorizePath: oauth2_auth_path
	  }
	});
		
	// Authorization uri definition
	this.authorizationUri = this.oauth2.authorizationCode.authorizeURL({
	  redirect_uri: oauth2_redirect_uri,
	    //scope: 'read,write',
		state: '3(#0/!~',
	});	
}	

// get /oauth
OAuth2.prototype.auth = function(req, res, next) {
  // console.log(this.authorizationUri);
  res.redirect(this.authorizationUri);
};

// get /callback
OAuth2.prototype.callback = function(req, res, callback) {
  const code = req.query.code;
  const options = {
    code: code,
    redirect_uri: this.oauth2_redirect_uri
  };

  this.oauth2.authorizationCode.getToken(options, (error, result) => {
    if (error) {
      console.error('Access Token Error', error.message);
      callback('Authentication failed: '+error.message, null);
    }
    else{
        // console.log('The resulting token: ', result);
        const token_obj = this.oauth2.accessToken.create(result);
        callback(null, token_obj.token);
    }
    res.send('<html><head></head><body onload="javascript:window.close();"></body></html>');
    res.status(200);
  });

};

module.exports = OAuth2;
