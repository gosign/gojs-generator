
# gojs-generator

gojs-generator is a Ruby command-line utility script that generates a TYPO3 extension "wrapper" around a JavaScript library, so that they can be managed through the extension manager.

It generates the following structure:

* `gojs_{extname}`
    * assets
        * CSS, images, ...
    * src
        * JavaScript files
    * `ext_emconf.php`
    * `ext_icon.gif`
    * `ext_typoscript_setup.txt`



# Example command

    gojs-gen.rb -js-version 0.1 \\
        --ext-name fbfriendselector \\
        --author "Lucas Jenss" \\
        --title "jQuery Facebook Friend Selector" \\
        somedir/some.css somedir/some.js \\
        somedir/some1.js somedir/some.png

For information on the parameters please refer to `gojs-gen.rb --help`.



# License

See `LICENSE` file.
