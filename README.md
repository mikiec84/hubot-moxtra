## hubot-moxtra

Hubot-Moxtra is an adapter that connects your [Hubot][hubot] scripts to your [Moxtra][moxtra] team, providing you one way to have your own [Chat bot][bot-docs].

Hubot, out of the box, is a framework to build chat bots, modeled after GitHub's Campfire bot of the same name, hubot. He's pretty cool. He's extendable with scripts and can work on many different chat services. With Moxtra's adapter you can now connect your Hubot to your Moxtra's binders and create your own scripts to interact with your team inside a Moxtra Chat.

[hubot]: http://hubot.github.com
[moxtra]: http://www.moxtra.com
[bot-docs]: https://developer.moxtra.com/docs/docs-bot-sdk/

## Requirements and Installation

You will need [Node.js, NPM][tutorial], [Yeoman][yo-link], [Moxtra account][moxtra] and a public server with a HTTPS domain in order to setup your Bot server and connect it to your Moxtra binders. 
PS. If you don't have the server and the HTTPS, no worries, you can get a free one from [Pivotal][pivotal]. 

To install, you will first need to create a new Hubot project:

    npm install -g yo generator-hubot

This will give us the hubot yeoman generator. Now we can make a new directory, and generate a new instance of hubot in it. For example, if we wanted to make a bot called myhubot:

    % mkdir myhubot
    % cd myhubot
    % yo hubot --adapter=moxtra

At this point, you’ll be asked a few questions about who is creating the bot.

You can always check out [Hubot Documentation][hubot-docs] to find more detailed explanation in how to Get Started with Hubot.

Once the installation is done, you can run your server.

[tutorial]: https://docs.npmjs.com/getting-started/installing-node
[hubot-docs]: https://hubot.github.com/docs/
[pivotal]: https://pivotal.io/
[yo-link]: http://yeoman.io/


## Running your Hubot

To run your server, first you have to set up the following Environment Variables. It can either be done using .env file or through the command line at the time you are starting the server.

    HUBOT_MOXTRA_CLIENTID=your_client_id
    HUBOT_MOXTRA_SECRET=your_secret
    HUBOT_MOXTRA_ENV=[SANDBOX | DEVELOPMENT]

In order to get the values for those variable, first you will need to [create a Bot][createbot] in Moxtra Platform. It will provide you the Client ID and the Client Secret. 
You will not complete the Bot creation process until we have the server running into a HTTPS url. So, for now, just get the Client ID and the Client Secret from Moxtra Bot creation screen.

Now you can run the following command to run your server:

    % HUBOT_MOXTRA_CLIENTID=your_client_id HUBOT_MOXTRA_SECRET=your_secret HUBOT_MOXTRA_ENV=SANDBOX  bin/hubot -a moxtra

If you created the Environment Variables in the .env file you just need to run the following command:

    % bin/hubot -a moxtra

At this point you will have the server running the default Hubot, but it's not connect to your Moxtra Binder yet.

Open your browser and check for a Sucess page in the url:

    http://localhost:8080/hubot/test 

You should receive a message like this:

   "Hi there! Your Hubot server with Moxtra Adapter is up and running!"

If you get that message you are good to go. Otherwise, try to check if you go any error in you NodeJS console, if your local url and port are correct.

Time to send your code to a public server and a HTTPS url.

[createbot]: https://developer.moxtra.com/nextbots

## Sandbox

You can create your Bot in our Sanbox Environmet to set up your Bot and do some tests with [Moxtra Sandbox][sandbox].

If you are using Sandbox you should inform the Environment Variables HUBOT_MOXTRA_ENV=SANDBOX when running your server.

[sandbox]: https://sandbox.moxtra.com

## Deploying

Get a NodeJS server, upload your hubot to the server and run:

    % HUBOT_MOXTRA_CLIENTID=your_client_id HUBOT_MOXTRA_SECRET=your_secret bin/hubot -a moxtra

If you created the Environment Variables in the .env file you just need to run the following command:

    % bin/hubot -a moxtra

If you are using [Pivotal][pivotal] you can run the following commands:

    1. Create an account
        https://console.run.pivotal.io/

    2. Create a project
        project/org:  moxtrabot

    3. Install Cloud Foundry CLI
        https://github.com/cloudfoundry/cli

    4. Publish to CF
        % cf login -a https://api.run.pivotal.io
        % cd myhubot
        % cf push hubot-moxtra -c "HUBOT_MOXTRA_CLIENTID=your_client_id HUBOT_MOXTRA_SECRET=your_secret bin/hubot -a moxtra"

Ps.: you should set the HUBOT_MOXTRA_ENV=SANDBOX environment variable if you [created your Bot][createbot] in the Sandbox Environment. For Production you don't need to specify the HUBOT_MOXTRA_ENV. The adapter will assume it is Production.

[pivotal]: https://pivotal.io/

## Tests

Once your server is up and running, check if it can respond to a https request:

    https://your-bot-url/hubot/test 

You should receive a message like this:

   "Hi there! Your Hubot server with Moxtra Adapter is up and running!"

## Linking you Hubot with Moxtra

Now that you have your server up and running you should finish the [Bot creation][createbot] process that you started earlier.

Please, go back to the [Bot creation][createbot] screen and fill out the field called "Callback URL" with your bot url plus "/hubot/webhooks" to look like this:

    https://your-domain/hubot/webhooks 

After that, give your bot some name, description, set the events you want to trigger and create your bot.

Once your Bot is validated and created, you just need to login your Moxtra Account (Production or Sandbox) and follow the steps:

    1. Create a new "Group Conversation" binder
    2. Include at least yourself in that binder
    3. Go to "Integrations"
    4. Go to "Bots"
    5. Look for the Bot you created, click in it and select Install
    6. Select the Binder you created on step 1 or any other binder you want to install the Bot

## Linking 3rd party accounts / OAuth2

You can connect your Moxtra Hubot to Third-party apps using [OAuth2][oauth2].
For example, you can use your Bot to bring to the chat some files from your [Dropbox][dropbox] account or any other third-party app that supports OAuth2. You just need to set up the following Environment Variables in your .env file:

    HUBOT_OAUTH2_CLIENT_ID= YOUR-3RD-PARTY-CLIENT-ID
    HUBOT_OAUTH2_CLIENT_SECRET= YOUR-3RD-PARTY-SECRECT
    HUBOT_OAUTH2_ENDPOINT= https://third-party-uri
    HUBOT_OAUTH2_AUTH_PATH= /oauth/authorize
    HUBOT_OAUTH2_TOKEN_PATH= /oauth/token
    HUBOT_OAUTH2_REDIRECT_URI= https://your-bot-url/hubot/oauth2/callback

The adapter will do all the Authentication process work to get the job done for you. It will open up a windows for the user to log into their account and will send back to your scripts the JSON Token Object, like this:

    {  
        "access_token": "AAAV82AAAV82AAAV82AAAV82AAAV82AAAV82AAAV82AAAV82AAAV82AAAV82AAAV82AAAV82AAAV82AAAV82AAAV82AAAV82AAAV82AA",
        "token_type": "bearer",
        "refresh_token": "MzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIxMMzIx",
        "expires_in": 43199,
        "scope": "read write",
        "expires_at": "2017-10-20T09:52:33.925Z"
    }

From there, you can call your third-party API to get the information you need direct from your Hubot Script folder.

[dropbox]: https://www.dropbox.com/developers/reference/oauth-guide
[oauth2]: https://oauth.net/2/

## Extending Hubot Capabilities

Hubot out of the box doesn’t do too much but it is an extensible, scriptable robot friend. There are hundreds of scripts written and maintained by the community and it’s easy to write your own. You can create a custom script in hubot’s scripts directory or create a script package for sharing with the community!

## Moxtra Adapter Features and Examples

Here you can find [examples][mxexample] on how to handle Moxtra's Events:

    - "bot_installed"
    - "bot_uninstalled"
    - Sending text, rich messages and buttons
    - Handling Buttons Postback
    - Sending Files
    - Linking 3rd party accounts using OAuth2

    https://github.com/moxtra/moxtra-sample-hubot/tree/master/scripts/moxtra-example.coffee 

Also, you can download the [moxtra-sample-hubot][msample] code and play with that in your Moxtra Binder.
    
[mxexample]: https://github.com/moxtra/moxtra-sample-hubot/tree/master/scripts/moxtra-example.coffee
[msample]: https://github.com/Moxtra/moxtra-sample-hubot

## License

See the LICENSE file for license rights and limitations (MIT).