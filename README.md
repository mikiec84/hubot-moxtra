## hubot-moxtra

Hubot-Moxtra is an adapter that connects your [Hubot][hubot] scripts to your [Moxtra][moxtra] team, providing you one way to have your own Chat bot.

Hubot, out of the box, is a framework to build chat bots, modeled after GitHub's Campfire bot of the same name, hubot. He's pretty cool. He's extendable with scripts and can work on many different chat services. With Moxtra's adapter you can now connect your Hubot to your Moxtra's binders and create your own scripts to interact with your team inside a Moxtra Chat.

[hubot]: http://hubot.github.com
[moxtra]: http://www.moxtra.com


## Requirements and Installation

You will need [Node.js, NPM][tutorial], [Yeoman][yo-link] and a public server with a HTTPS domain in order to setup your Bot server and connect it to your Moxtra binders. 
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

To run your server, first you have to set up some Environment Variables:

    HUBOT_MOXTRA_TOKEN=your_token
    HUBOT_MOXTRA_SECRET=your_secret
    HUBOT_MOXTRA_ENV=SANDBOX

In order to get the values for those variable, first uou will need to [create a Bot][createbot] in Moxtra Platform. It will provide you the Client Secret and the Verify Token. 
You will not complete the Bot creation process until we have the server running into a HTTPS url. So, for now, just get the Client Secret and define a random Verify Token.

Now you can run the following command to run your server:

    % HUBOT_MOXTRA_TOKEN=your_token HUBOT_MOXTRA_SECRET=your_secret HUBOT_MOXTRA_ENV=SANDBOX  bin/hubot -a moxtra

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

Get a NodeJS server, upload your myhubot to the server and run:

    % HUBOT_MOXTRA_TOKEN=your_token HUBOT_MOXTRA_SECRET=your_secret bin/hubot -a moxtra

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
        % cf push hubot-moxtra -c "HUBOT_MOXTRA_TOKEN=your_token HUBOT_MOXTRA_SECRET=your_secret bin/hubot -a moxtra"

Ps.: you should include HUBOT_MOXTRA_ENV=SANDBOX in the command if you [created your Bot][createbot] in the Sandbox Environment.

[pivotal]: https://pivotal.io/

## Tests

Once your server is up and running, check if it can respond to a https request:

    https://yoururl/hubot/test 

You should receive a message like this:

   "Hi there! Your Hubot server with Moxtra Adapter is up and running!"

## Linking you Hubot with Moxtra

Now that you have your server up and running you should finish the [Bot creation][createbot] process that you started earlier.

You should provide in the screem your HTTPS url, give your bot some name, description, set the events you want to trigger, validate and create your bot.

Once your Bot is validated and created, you just need to login your Moxtra Account (Production or Sandbox) and follow the steps:

    1. Create a new "Group Conversation" binder
    2. Include at least yourself in that binder
    3. Go to "Integrations"
    4. Go to "Bots"
    5. Look for the Bot you created, click in it and select Install
    6. Select the Binder you created on step 1 or any other binder you want to install the Bot


## Extending Hubot Capabilities

    Hubot out of the box doesn’t do too much but it is an extensible, scriptable robot friend. There are hundreds of scripts written and maintained by the community and it’s easy to write your own. You can create a custom script in hubot’s scripts directory or create a script package for sharing with the community!

## Moxtra Adapter Features and Examples

Here you can find [examples][mxexample] on how to handle Moxtra's Events:

    - "bot_installed"
    - "bot_uninstalled"
    - Sending Buttons
    - Handling Buttons Postback
    - Sending Files

    https://github.com/moxtra/moxtra-sample-hubot/tree/master/scripts/moxtra-example.coffee 

Also, you can download the [moxtra-sample-hubot][msample] code and play with that in your Moxtra Binder.
    
[mxexample]: https://github.com/moxtra/moxtra-sample-hubot/tree/master/scripts/moxtra-example.coffee
[msample]: https://github.com/Moxtra/moxtra-sample-hubot

## License

See the LICENSE file for license rights and limitations (MIT).