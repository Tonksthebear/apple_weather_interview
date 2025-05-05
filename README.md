# Weather App

## Installation

After cloning the repo
```bash
bundle install
bin/dev
```
Then you should be able to view the app on `localhost:3000`. No API keys needed

## Architecture
- Vanilla Rails (HOTWire) + Tailwind
- Form built with accessibility in mind using a component library I'm working on [headless-component-rails](https://github.com/Tonksthebear/headless-components-rails) ([link to demo site](https://headless-components-rails.onrender.com))
- ActiveRecord-esque API leveraging a custom [BaseResource](./models/base_resource.rb)
- Leverage CSS instead of javascript and/or erb conditionals when rendering different states
  - `not-has-[a]:hidden` Only show a box with links when there are links
  - `data-[name='']:hidden peer-[:has(a)]:hidden` Only show a warning that the search didn't 
  - Others throughout the views
- VCR gem for testing so that we don't needlessly spam endpoints when we're running tests

## Considerations
- In order to show that a page was cached, I had to disable [Turbo 8 prefetch](https://turbo.hotwired.dev/handbook/drive#prefetching-links-on-hover), otherwise the page would be cached before the link was clicked and would therefore always show the page as cached. In production, I would potentially re-enable this
- I built [BaseResource](./models/base_resource.rb) to mimic ActiveRecord in order to improve developer happiness when working with the API. The more rails-y, the better. I also built a light [association manager](./models/concerns/associations.rb). However, depending on if the production version would actually have a database, I would consider changing the DSL to differ more from ActiveRecord. It could be confusing to no know when data is coming from a database or remote API
- I would consider using a more battle-tested gem like [ActiveResource](https://github.com/rails/activeresource) in a production app. A homegrown solution can be great for small scopes, but may become difficult to maintain as feature scope grows. I didn't want to use it here so that I could demonstrate how I would build a lite version.
- I skipped testing for custom associations becuase realistically we'd use a gem already battle tested as discussed
- Visuals would need to be upgraded. Mobile responsiveness, more consideration with the high/low bars (I did some normalization of the data but there are no doubt better ways to do so)
- Define a more script rubocop style. The default rails-omakase is great for basics, but forgos any indentation decisions.