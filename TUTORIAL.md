# Creating a translator plugin

The following is a tutorial on how to create a translator that plugs in to bel.rb.

This tutorial follows the creation of a TAB-separated translator plugin for BEL Nanopubs. The corresponding example code repository is located at [OpenBEL/bel.rb-tsv-translator][OpenBEL/bel.rb-tsv-translator]. You can retrieve clone it using *git*:

```
git clone https://github.com/OpenBEL/bel.rb-tsv-translator
```

> Note
> Read [What are translators?][What are translators?] to learn about what a translator is and why you might want one.


#### Tutorial requirements:
- Ruby installation (Version 2.0.0 or higher)
- Familiarity with the command line of your operating system

#### Tutorial contents:
- [Create your project directory](#create-your-project-directory)
- [Describe your project as a Ruby gem](#describe-your-project-as-a-ruby-gem)
- [Create a Ruby file that defines your translator](#create-a-ruby-file-that-defines-your-translator)
- [Create a Ruby file for your translator implementation](#create-a-ruby-file-for-your-translator-implementation)
- [Implement read functionality](#implement-read-functionality)
- [Implement write functionality](#implement-write-functionality)
- [Package your project as a Ruby gem](#package-your-project-as-a-ruby-gem)
- [Install your Ruby gem](#install-your-ruby-gem)
- [Test your translator in bel.rb](#test-your-translator-in-belrb)

### Create your project directory

Your project deserves its own directory. It will group all of your project files in one place. This is also recommended for Ruby gems that are shared with others.

Create your project directory with:

```bash
mkdir "bel.rb-tsv-translator"
```

> Recommendation
> The project directory is recommended as "bel.rb-[YOUR PLUGIN ID]-translator". This describes your translator as integrating with bel.rb.
>
> This may not be suitable if your translator integrates with other libraries in addition to bel.rb.

### Describe your project as a Ruby gem

A Ruby gem must be described with author, files provides, and required library dependencies. This is captured by a [Rubygems specification][Rubygems specification].

Create the `.gemspec` file in the *bel.rb-tsv-translator* directory using your favorite text editor. Adjust the field values to suit your needs.

You can reference the [Rubygems specification][Rubygems specification] when more detail is needed on a particular field.

```ruby
# .gemspec

Gem::Specification.new do |s|
  s.name        = 'bel-tsv-translator'
  s.version     = '0.1.0'
  s.licenses    = ['Apache-2.0']
  s.summary     = 'A TAB-separated translator for BEL Nanopubs.'
  s.description = 'This translator provides read/write functionality for BEL Nanopubs stored in TAB-separated files. This translator is intended to integrate with bel.rb.'
  s.authors     = ['Your Name']
  s.email       = 'your@email.com'
  s.files       = [
    'lib/bel/translator/plugins/tsv.rb',
    'lib/bel/translator/plugins/tsv/translator.rb'
  ]
  s.homepage    = 'https://rubygems.org/gems/bel.rb-tsv-translator'

  # Dependency on the bel.rb library.
  s.add_runtime_dependency 'bel', '~> 0.5'
end
```


The translator depends on some code provides by bel.rb. We thus declare a dependency on the [bel][bel] gem. The *~> 0.5* semantic version specifier says that any version greater than or equal to *0.5.0* but less than *0.6.0* is acceptable. 

> Notes
> The pessimistic version specifier (known as [twiddle-waka](http://guides.rubygems.org/patterns/#pessimistic-version-constraint)) puts trust into [semantic versioning](http://semver.org/) and the rigor to which the authors follow it! The OpenBEL community projects strive to follow [semantic versioning](http://semver.org/).
> 
> The *name* field of your Ruby gem reflects your project directory except that *bel.rb* is changed to *bel* since we will use this name when publishing the Ruby gem. The *.rb* suffix denotes Ruby which is descriptive relative to the broader OpenBEL ecosystem.
>
> The *homepage* field is set to the location on [Rubygems.org][Rubygems.org] where most publicly-available Ruby gems are located. 
>
> We include the Ruby files that are available in this gem using the *files* field. These files make up the TSV translator code. These Ruby files, under the *lib/* directory, can be loaded into Ruby, at runtime, using *require*.


### Create a Ruby file that defines your translator

A translator plugin must be described in order to be available to bel.rb and be presentable to a user. We do this by creating a Ruby file under the project's *lib/bel/translator/plugins/* directory. This particular directory will be scanned, by the [bel][bel] gem, for Ruby modules declared within the `BEL::Translator::Plugins` module. Read [Plugins in bel.rb][Plugins in bel.rb] more more details on how plugins are declared and loaded.

First create the *lib/bel/translator/plugins* directory:

```bash
# Unix
mkdir -p lib/bel/translator/plugins

# Windows
mkdir \lib\bel\translator\plugins
```

Then create the *lib/bel/translator/plugins/tsv.rb* file using your favorite text editor:

```ruby
# lib/bel/translator/plugins/tsv.rb

require 'bel'

module BEL::Translator::Plugins

  module Tsv

    ID          = :tsv
    NAME        = 'Tab-separated Translator'
    DESCRIPTION = 'This translator provides read/write functionality for BEL Nanopubs stored in TAB-separated files. This translator is intended to integrate with bel.rb.'
    MEDIA_TYPES = %i(text/tab-separated-values)
    EXTENSIONS  = %i(tsv tab)

    def self.create_translator(options = {})
      require_relative 'tsv/translator'
      TsvTranslator.new
    end

    def self.id
      ID
    end

    def self.name
      NAME
    end

    def self.description
      DESCRIPTION
    end

    def self.media_types
      MEDIA_TYPES
    end 

    def self.file_extensions
      EXTENSIONS
    end
  end
end
```

Take particular notice of the `create_translator` method. It creates the Ruby object that provides *read* and *write* functionality. The implementation of our translator.

We will implement the `TsvTranslator` in the next step.

> Notes
> We `require 'bel'` in order to define the translator plugin system.
>
> We declare the `Tsv` module within the `BEL::Translator::Plugins` module defined by the [bel][bel] gem.
>
> We define the identifier, file extensions, and media types that can be used to retrieve this translator. Read [How are translators identified?][How are translators identified?] for more detail on translator identifiers.
> 
> We use `require_relative` to load a Ruby file that is resolved relative to the current file's directory.

### Create a Ruby file for your translator implementation

The translator implementation will be responsible for implementing *read* and *write, but for now we'll provide empty methods.

Create the *lib/bel/translator/plugins/tsv* directory:

```bash
mkdir lib/bel/translator/plugins/tsv
```

Now create the *lib/bel/translator/plugins/tsv/translator.rb* file using your favorite text editor:

```ruby
# lib/bel/translator/plugins/tsv/translator.rb

module BEL::Translator::Plugins::Tsv

  class TsvTranslator

    include ::BEL::Translator
    include ::BEL::Model

    def read(data, options = {})
      # Read data to a stream of BEL Nanopubs.
    end

    def write(nanopub_stream, output = StringIO.new, options = {})
      # Write a stream of BEL Nanopubs to some output.
    end
  end
end
```

We have now defined a `TsvTranslator` class that provides the *read* and *write* methods.

Next we will implement the *read* functionality for a TAB-separated format for BEL Nanopubs.

> Notes
> We reopen our `BEL::Translator::Plugins::Tsv` module that we defined in *lib/bel/translator/plugins/tsv.rb* and defined the `TsvTranslator` class.
>
> The `BEL::Translator` module is included in our translator. This module provides the abstract *read* and *write* methods. If these methods *are not* overridden in our translator then calling them will raise a `NotImplementedError`.
>
> We include the `BEL::Model` module in order to access BEL Nanopub objects by simpel class name (e.g. `Citation`).

### Implement read functionality

The *read* method's role is to obtain BEL Nanopubs from data and return an object that can be iterated by calling its `each` method.

This responsibility is straightforward to implement for TAB-separated files, because they are line-based. We can map one line to one BEL Nanopub in a streaming fashion.

Let us assume we will read the following fields:

| Position | Field    | Example Value                                                                                                                        |
|----------|---------------|--------------------------------------------------------------------------------------------------------------------------------------|
| 0        | Citation Type | PubMed                                                                                                                               |
| 1        | Citation Id   | 12928037                                                                                                                             |
| 2        | Support       | Arterial cells are highly susceptible to oxidative stress, which can induce both necrosisand apoptosis (programmed cell death) [1,2] |
| 3        | BEL Statement | bp(GOBP:"response to oxidative stress") increases bp(GOBP:"apoptotic process")                                                       |

Open up *lib/bel/translator/plugins/tsv/translator.rb* and replace the empty *read* method with the following:

```ruby
def read(data, options = {})
  data.each_line.map { |line|
    ctype, cid, support, statement = line.strip.split("\t")
    bel_nanopub = Evidence.create(
      citation:      Citation.new(type: ctype, id: cid),
      summary_text:  SummaryText.new(support),
      bel_statement: statement   
    )

    bel_nanopub.bel_statement = Evidence.parse_statement(bel_nanopub)

    bel_nanopub
  }
end
```

We have transformed our TAB-separated file into BEL Nanopubs line by line. The return value for *read* will be an `Enumerator` of `BEL::Model::Evidence` objects that represents the stream of BEL Nanopubs.

We have now satisfied our *read* responsibility! Great job.

> Notes
> The return value of the *read* method will be the result of `data.each_line.map`. In Ruby the last line of the enclosing scope (e.g. block, method) is returned.
>
> The block provided to the *map* function must return a transformed result for each line given. In our case we transform each line into a BEL Nanopub according to our TAB Format. The last line of the *map* block, `bel_nanopub`, will be its return value.

### Implement write functionality

The *write* method's role is to write a stream of BEL Nanopubs to some output. Your *write* method should support writing to any [Ruby IO][Ruby IO] object.

Again, let us assume we will write the following fields:

| Position | Field    | Example Value                                                                                                                        |
|----------|---------------|--------------------------------------------------------------------------------------------------------------------------------------|
| 0        | Citation Type | PubMed                                                                                                                               |
| 1        | Citation Id   | 12928037                                                                                                                             |
| 2        | Support       | Arterial cells are highly susceptible to oxidative stress, which can induce both necrosisand apoptosis (programmed cell death) [1,2] |
| 3        | BEL Statement | bp(GOBP:"response to oxidative stress") increases bp(GOBP:"apoptotic process")                                                       |

Open up *lib/bel/translator/plugins/tsv/translator.rb* and replace the empty *write* method with the following:

```ruby
def write(nanopub_stream, output = StringIO.new, options = {})
  nanopub_stream.each do |evidence|
    output << (
      [
        evidence.citation.type,
        evidence.citation.id,
        evidence.summary_text.to_s.gsub("\n", ""),
        evidence.bel_statement
      ].join("\t") + "\n"
    )
  end

  output
end
```

We have now satisfied our *write* responsibility! Great job.

Now we can package up our masterpiece as a Ruby gem.

> Notes
> The *output* parameter has a default value of [StringIO](http://ruby-doc.org/stdlib/libdoc/stringio/rdoc/StringIO.html). This will buffer the output to a Ruby string.

> The `do...end`block style is used to indicate the side effect of writing to *output*. Contrast this with the `{...}` block syntax which is intended to have a return value and optional chaining of addition methods (e.g. `data.map { |x| ... }.each { |x| ...}`).

> We return the [Ruby IO][Ruby IO] parameter as a convenience to the caller.

### Package your project as a Ruby gem

Remember that *.gemspec* file you created back in [Describe your project as a Ruby gem](#describe-your-project-as-a-ruby-gem)?

It contains project information and dependencies needed to package our library. Go ahead and build it using [RubyGems](http://guides.rubygems.org/rubygems-basics/):

```
gem build .gemspec
```

You should see something like:

```
Successfully built RubyGem
Name: bel-tsv-translator
Version: 0.1.0
File: bel-tsv-translator-0.1.0.gem
```

Great work! Continue on to install.

### Install your Ruby gem

You should now have a *bel-tsv-translator-0.1.0.gem* file in the project directory.

You can install the gem into Ruby with:

```
gem install bel-tsv-translator-0.1.0.gem
```

You should see something like:

```
Fetching: bel-0.5.0.gem (100%)
Building native extensions.  This could take a while...
Successfully installed bel-0.5.0
Successfully installed bel-tsv-translator-0.1.0
Parsing documentation for bel-0.5.0
Installing ri documentation for bel-0.5.0
Parsing documentation for bel-tsv-translator-0.1.0
Done installing documentation for bel, bel-tsv-translator after 5 seconds
2 gems installed
```

Remember, we declared a project dependency on the *bel* gem so that will be installed if necessary.

### Test your translator in bel.rb

Now that you have *bel-tsv-translator* and *bel* installed you are ready to test it out.

Start by listing the plugins available using the `bel` command:

```
bel plugins --list
```

You should see the TAB-separated translator under the *Translator plugins* section:

```
...
 Name:        Tab-separated Translator
 Description: This translator provides read/write functionality for BEL Nanopubs stored in TAB-separated files. This translator is intended to integrate with bel.rb.
...
```

You could also try converting your favorite BEL Script file to our shiny new TAB-separated format:

```
bel translate -i fav.bel bel_script tsv
```

Here is a quick example using standard input within a Unix shell.

Given a single BEL Nanopub named *example.bel*:

```bel
# example.bel
SET Citation = {"PubMed","Trends in molecular medicine","12928037","","de Nigris F|Lerman A|Ignarro LJ|Williams-Ignarro S|Sica V|Baker AH|Lerman LO|Geng YJ|Napoli C",""}

SET Evidence = "Aging, one of the major predictors for atherosclerotic lesion formation, increases the sensitivity of endothelial cells to apoptosis induced by in vitro and in vivo stimuli [35–37]."

bp(GOBP:aging) increases bp(GOBP:"apoptotic process")
```

We can translate this BEL Nanopub to TAB-separated format with:

```
cat example.bel | bel translate bel_script tsv 
```

The output should be:

```tsv
PubMed	12928037	Aging, one of the major predictors for atherosclerotic lesion formation, increases the sensitivity of endothelial cells to apoptosis induced by in vitro and in vivo stimuli [35–37].	bp(GOBP:aging) increases bp(GOBP:"apoptotic process")
```

### Wrap up

Great job.

The hope is that plugins our easy to integrate within the *bel* gem. If you find that this is not the case please [open an issue](https://github.com/OpenBEL/bel.rb/issues/new).

[Plugins in bel.rb]: https://github.com/OpenBEL/bel.rb/wiki/Plugins-in-bel.rb
[Creating a translator plugin]: https://github.com/OpenBEL/bel.rb/wiki/Creating-a-translator-plugin
[What are translators?]: https://github.com/OpenBEL/bel.rb/wiki/Using-translators#what-are-translators
[OpenBEL/bel.rb-tsv-translator]: https://github.com/OpenBEL/bel.rb-tsv-translator
[Rubygems specification]: http://guides.rubygems.org/specification-reference/
[Rubygems.org]: https://rubygems.org/
[bel]: https://rubygems.org/gems/bel
[How are translators identified?]: https://github.com/OpenBEL/bel.rb/wiki/Using-translators#how-are-translators-identified
[Ruby IO]: http://ruby-doc.org/core/IO.html
