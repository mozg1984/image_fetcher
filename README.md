# Console utility for downloading images
This console utility is designed to download images from various sources over the network.

To improve the reliability of downloading files, the gem [down](https://github.com/janko/down) was taken as a basis. Using this gem allows to control the downloading process. It also protects against endless downloads of files and downloads of very large files.

To increase the speed of downloading files, the gem [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby) was taken as a basis. For optimization purposes, the parallel loading of files is performed on the basis of a pool of threads (analogue from the Java world). The thread pool allows to download files from the minimum (default `= 2`, you can set it in the config file via the field `min_threads`) to the supported number of threads on your machine (or set in the config file via the field `max_threads`). All added files are queued in this thread pool for download one by one.

For more detailed settings for downloading files, please refer to the settings file - `settings.yml`.

In cases of abnormal situations with individual downloading files, the downloading process itself is not interrupted. For each case, information will be printed to the `STDOUT`. This eliminates problems associated with incorrect url-links and network problems:
```sh
$ bin/image_fetcher -f './spec/fixtures/files/image_links' -d '.'
An error occurred while downloading the file http://placehold.it/120x120&text=image2: timed out waiting for connection to open
An error occurred while downloading the file http://placehold.it/120x120&text=image1: timed out waiting for connection to open
An error occurred while downloading the file http://placehold.it/120x120&text=image4: timed out waiting for connection to open
An error occurred while downloading the file http://placehold.it/120x120&text=image3: timed out waiting for connection to open
An error occurred while downloading the file http://placehold.it/120x120&text=image5: timed out waiting for connection to open
```

The modular system and the configuration file allow you to expand the functionality of this application if necessary.

### Requirements
- Ruby 3.0.0
- Bundler version 2.2.15

### Installation
`$ bundle install`

Grant execute permissions:
`$ chmod +x bin/image_fetcher`

After installation, to be sure that everything is installed well, run the tests:
`$ bundle exec rspec`

### Execution
For execution, you need to specify two options: `-f | --file` (source file with url-links) and `-d | --directory` (destination directory where files will be stored).  

```sh
$ bin/image_fetcher -h                                            
Usage: image_fetcher [options]
    -f, --file PATH                  The file path with url-links
    -d, --directory PATH             The directory path for saving downloaded image
```

Example:
`$ bin/image_fetcher -f './spec/fixtures/files/image_links' -d '.'`
