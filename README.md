# About Glitter

Glitter is an easy way to publish native application software updates to an Amazon S3 bucket. It was created at Poll Everywhere to eliminate the need maintaining additional server infrastructure for rolling out native desktop software updates. Glitter works with various "Sparkle" frameworks including:

* Sparkle - http://sparkle.andymatuschak.org/
* NetSparkle - http://netsparkle.codeplex.com/

Glitter also supports the concepts of release channels, which makes it possible to have development, nightly, staging, beta, or production releases all from the command line interface. Release channels make it easier for developers to collaborate with customers and product owners about product features.

# Getting started

1.  Install the gem.

    ```sh
    $ gem install glitter
    ```

2. Publish your app to the web.

    ```sh
    $ AWS_ACCESS_KEY_ID=secret_access_key \
        AWS_SECRET_ACCESS_KEY=access_key_id \
        AWS_BUCKET_NAME=my-app-bucket \
        glitter push my-app.dmg -v 1.2.5 -c "mac-edge" \
        -n 'Added some really cool stuff to the mix!'
    
    Pushing app my-app.dmg to https://s3.amazonaws.com/mac-edge/1.2.5/my-app.dmg
    Updated head https://s3.amazonaws.com/mac-edge/my-app.dmg to https://s3.amazonaws.com/mac-edge/1.2.5/my-app.dmg
    ```

3.  Distribute the link to your app.

    https://s3.amazonaws.com/mac-edge/my-app.dmg is the "current" version of your application and a history is maintained with https://s3.amazonaws.com/mac-edge/1.2.5/my-app.dmg assets. You'll probably want to link to the "head" asset of your app and keep the older builds around for troubleshooting purposes.
    
    If you want a vanity URL to distribte your app, setup a redirect like this in nginx:
    
        rewrite ^/my-app.zip$ https://s3.amazonaws.com/mac-edge/my-app.dmg;
    
    Now send your users to mydomain.com/my-app.zip and they'll get the latest version of your app. I don't recommend using a CNAME with your application because it won't work with Amazon's HTTPS servers and you'll have to jump through some hoops to sign your app distributions with a DSA signature. Not worth it in my opinion.

# Contribute

Want to hack on glitter? Awesome! You'll need to setup an S3 bucket and run specs with the `AWS_URL` env var specified:

```sh
$ AWS_ACCESS_KEY_ID=secret_access_key \
    AWS_SECRET_ACCESS_KEY=access_key_id \
    AWS_BUCKET_NAME=my-app-bucket \
    bundle exec rspec
```

Prefer to use Foreman? Create a `.env` file in the root of the project, then paste:

```sh
AWS_ACCESS_KEY_ID=secret_access_key
AWS_SECRET_ACCESS_KEY=access_key_id
AWS_BUCKET_NAME=my-app-bucket
```

and run specs via:

```sh
foreman run bundle exec rspec
```

Pretty sweet eh? That's it!

# Upgrading from Glitter 1.x?

Glitter 2.0 is not backwards compatible with Glitter 1.x. To migrate from 1.x you'll need to specify a release channel like `my-app-production`, note the URL of the binary asset here, and manually change the 1.0 appcast.xml entry to point to the new Glitter 2.0 release channel.

# License

Copyright (C) 2011 by Brad Gessler

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
