Watered-down sauces are often gross. So is FED testing. WatirSauce tries to make testing FED changes in a variety of browsers easier to swallow. 

## What is it?

Levaraging [SauceLabs](https://saucelabs.com) and WatirWebdriver, WatirSauce allows you to configure a YAML file, run a command, and take screenshots in all of your favorite browsers. It also supports parallel execution. This reduces the amount of time required to test 2 pages on 15 browsers down from 45 minutes to less than 5.

## Requirements

* SauceLabs account
* OS X, possibly Linux. Maybe Windows?
* The provided code

## Installation

```
git clone git@github.com:ClockworkNet/watirsauce.git
cd watirsauce
bundle install
```

## Usage

```
bundle exec bin/watirsauce
```

## Configuration

Two things must be configured to use WatirSauce:

* Environment Variables

Update your `~/.bash_profile` file with the following lines, using the values for your Sauce Account.

    export SAUCE_USERNAME=<your_sauce_username>
    export SAUCE_ACCESS_KEY=<your_sauce_access_key>

Note: It is necessary to type `source ~/.bash_profile` or open a new terminal window after updating the file.

  * Configure a YAML file for use. See the included `sample_site_config.yaml` for an example
      * The YAML file includes a few main sections:
        * `browsers` - the browser and OS configurations to test
        * `vm_limit` - The # of parallel screenshots to take - you should update this (default: 1)
        * `live_site` - the base domain, without protocol (`clockwork.net`)
        * `pages` - the paths to pages to screenshot (`/blog/`, `/work/`)
        * `actions` - Actions that should occur on certain pages. Ask for details.
        * `sauce_connect` settings - Test a local instance

## How to use
* cd into the `watirsauce` directory
* `./bin/watirsauce sample_site_config.yaml`
* All screenshots will end up in a folder named after the domain. They are named in a pattern like `[path_to_page-browser-combination.png]`.

Screenshots are easily reviewed using OS X Finder, and Quicklook (Space bar and arrow keys) or the Preview App.

## License

See LICENSE.

## Credits

 * [Andie Leaf](https://github.com/avleaf) - author, maintainer
