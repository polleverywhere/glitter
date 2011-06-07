# About Glitter

Glitter is an easy way to publish Mac software updates to an Amazon S3 bucket using the Sparkle framework (http://sparkle.andymatuschak.org/). It was created at Poll Everywhere to eliminate the need maintaining additional server infrastructure for rolling out Mac desktop software updates. 

It should also be noted that Glitter uses HTTPS S3 URLs to eliminate the need for the maintiance of public/private keys for Sparkle, which further simplifies the publishing process.

# Getting started

1.  Install the gem

        $ gem install glitter

2.  Generate a Glitterfile in your project directory

        $ glitter init .

3.  Edit the Glitterfile

        # After you configure this file, deploy your app with `glitter push`
        name          "My App"
        version       "1.0.0" # Don't forget, its ruby! This could read a version from a plist file
        archive       "my_app.zip"
        
        s3 {
          bucket_name       "my_app"
          access_key        "access"
          secret_access_key "sekret"
        }

4. Publish your app to the web

        $ glitter push -m 'Added some really cool stuff to the mix!'
        Pushing app my-app-1.0.0.zip
        Asset pushed to https://s3.amazonaws.com/my_app/my-app-1.0.0.zip
        Updated head https://s3.amazonaws.com/my_app/my-app-head.zip to https://s3.amazonaws.com/my_app/my-app-1.0.0.zip
        Updated https://s3.amazonaws.com/my_app/appcast.xml

That's it!

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