# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{milk}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Caswell"]
  s.date = %q{2009-06-28}
  s.default_executable = %q{milk}
  s.email = %q{tim@creationix.com}
  s.executables = ["milk"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/milk",
     "lib/milk.rb",
     "lib/milk/application.rb",
     "lib/milk/component.rb",
     "lib/milk/field.rb",
     "lib/milk/page.rb",
     "lib/milk/tasks.rb",
     "milk.gemspec",
     "site_template/Rakefile",
     "site_template/bootstrap.rb",
     "site_template/config.ru",
     "site_template/data/global/foot.yaml",
     "site_template/data/global/head.yaml",
     "site_template/data/pages/About.yaml",
     "site_template/data/pages/Home.yaml",
     "site_template/data/pages/News.yaml",
     "site_template/data/pages/NotFound.yaml",
     "site_template/data/pages/Products.yaml",
     "site_template/lib/components/body.rb",
     "site_template/lib/components/button.rb",
     "site_template/lib/components/foot.rb",
     "site_template/lib/components/head.rb",
     "site_template/lib/fields/checkbox_field.rb",
     "site_template/lib/fields/component_array.rb",
     "site_template/lib/fields/dropdown_field.rb",
     "site_template/lib/fields/image_chooser.rb",
     "site_template/lib/fields/markdown_field.rb",
     "site_template/lib/fields/page_chooser.rb",
     "site_template/lib/fields/sprite_chooser.rb",
     "site_template/lib/fields/text_field.rb",
     "site_template/public/cache/About/index.html",
     "site_template/public/cache/Home/index.html",
     "site_template/public/cache/News/index.html",
     "site_template/public/cache/Products/index.html",
     "site_template/public/favicon.ico",
     "site_template/public/images/README.txt",
     "site_template/public/js/edit.js",
     "site_template/public/js/form_validate.js",
     "site_template/public/js/jquery-1.3.2.min.js",
     "site_template/public/js/jquery-ui-1.7.2.custom.min.js",
     "site_template/public/js/jquery.json-1.3.min.js",
     "site_template/public/js/login.js",
     "site_template/public/robots.txt",
     "site_template/public/skin/images/ui-bg_diagonals-thick_18_b81900_40x40.png",
     "site_template/public/skin/images/ui-bg_diagonals-thick_20_666666_40x40.png",
     "site_template/public/skin/images/ui-bg_flat_10_000000_40x100.png",
     "site_template/public/skin/images/ui-bg_glass_100_f6f6f6_1x400.png",
     "site_template/public/skin/images/ui-bg_glass_100_fdf5ce_1x400.png",
     "site_template/public/skin/images/ui-bg_glass_65_ffffff_1x400.png",
     "site_template/public/skin/images/ui-bg_gloss-wave_35_f6a828_500x100.png",
     "site_template/public/skin/images/ui-bg_highlight-soft_100_eeeeee_1x100.png",
     "site_template/public/skin/images/ui-bg_highlight-soft_75_ffe45c_1x100.png",
     "site_template/public/skin/images/ui-icons_222222_256x240.png",
     "site_template/public/skin/images/ui-icons_228ef1_256x240.png",
     "site_template/public/skin/images/ui-icons_ef8c08_256x240.png",
     "site_template/public/skin/images/ui-icons_ffd27a_256x240.png",
     "site_template/public/skin/images/ui-icons_ffffff_256x240.png",
     "site_template/public/skin/jquery-ui-1.7.2.custom.css",
     "site_template/public/style/960.css",
     "site_template/public/style/edit.css",
     "site_template/public/style/login.css",
     "site_template/public/style/reset.css",
     "site_template/public/style/style.css",
     "site_template/public/style/text.css",
     "site_template/public/style/view.css",
     "site_template/templates/960.sass",
     "site_template/templates/components/body.haml",
     "site_template/templates/components/button.haml",
     "site_template/templates/components/foot.haml",
     "site_template/templates/components/head.haml",
     "site_template/templates/dependencies.haml",
     "site_template/templates/edit.component.haml",
     "site_template/templates/edit.haml",
     "site_template/templates/edit.sass",
     "site_template/templates/fields/checkbox_field.haml",
     "site_template/templates/fields/component_array.haml",
     "site_template/templates/fields/dropdown_field.haml",
     "site_template/templates/fields/image_chooser.haml",
     "site_template/templates/fields/markdown_field.haml",
     "site_template/templates/fields/page_chooser.haml",
     "site_template/templates/fields/sprite_chooser.haml",
     "site_template/templates/fields/text_field.haml",
     "site_template/templates/login.haml",
     "site_template/templates/login.sass",
     "site_template/templates/reset.sass",
     "site_template/templates/text.sass",
     "site_template/templates/view.haml",
     "site_template/templates/view.page.haml",
     "site_template/templates/view.sass",
     "site_template/tmp/restart.txt",
     "test/milk_test.rb",
     "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/creationix/milk}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8")
  s.rubyforge_project = %q{milk}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Milk is a rack based content management system built for ease of use and simplicity. Milk tastes great with and without cookies.}
  s.test_files = [
    "test/test_helper.rb",
     "test/milk_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<maruku>, [">= 0.6.0"])
      s.add_runtime_dependency(%q<haml>, [">= 2.0.9"])
    else
      s.add_dependency(%q<rack>, [">= 1.0.0"])
      s.add_dependency(%q<maruku>, [">= 0.6.0"])
      s.add_dependency(%q<haml>, [">= 2.0.9"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.0.0"])
    s.add_dependency(%q<maruku>, [">= 0.6.0"])
    s.add_dependency(%q<haml>, [">= 2.0.9"])
  end
end
