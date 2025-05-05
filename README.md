# Weather App

## Installation

After cloning the repo
```bash
bundle install
bin/dev
```
Then you should be able to view the app on `localhost:3000`. No API keys needed

## Architecture
- **Tech Stack**: Vanilla Rails (HOTWire) + Tailwind
- **Accessible Forms**: Built with [headless-component-rails](https://github.com/Tonksthebear/headless-components-rails), a library I built for accessible, reusable ViewComponents ([demo site](https://headless-components-rails.onrender.com))
- **API Layer**: Custom DSL mimicking ActiveRecord for Rails-y interactions
- **CSS Driven States**: Leverage CSS over javascript and/or erb conditionals, for example:
  - `not-has-[a]:hidden`: Hides list when no links are present
  - `data-[name='']:hidden peer-[:has(a)]:hidden`: Only show "No results" message if no links were found when a search name is present 
  - Others examples throughout the views
- **Testing**: Uses VCR gem for testing in order to optimize API usage

## Considerations
### Turbo Prefetch
Turbo 8 defaults to enabling [prefetch)(https://turbo.hotwired.dev/handbook/drive#prefetching-links-on-hover on links. While this enables faster response time on clicking links, it can break the indicator for displaying if the page is cached if the user does not click the link the first time they hover over it. Caching occurs when retrieving data for the #show endpoint. Prefetching will hit the #show endpoint on every hover, thus caching the data ahead of the user actually visiting the page. If the user hovers multiple times before visiting a location, the data will be cached by the time the visit.

Prefetching can be valuable for user experience, so I would consider enabling this in an actual production app.

### Custom BaseResource DSL
I built [BaseResource](./models/base_resource.rb) to mimic ActiveRecord in order to improve developer happiness when working with the API. The more rails-y, the better. Compartmentalizing endpoints in models also helps improve unit testing through modularization. 

I also built a light [association manager](./models/concerns/associations.rb) in order to mimic ActiveRecord associations. This could be deemed overly-complex for this assignment, but I personally would consider a feature like associations to be the scalable way to handle API relationships. However, depending on if the production version would actually have a database, I would consider changing the DSL to differ more from ActiveRecord so as to avoid confusion about whether data comes from a database or remote API.

I would consider using a more battle-tested gem like [ActiveResource](https://github.com/rails/activeresource) in a production app. A homegrown solution can be great for small scopes, but may become difficult to maintain as feature scope grows. I didn't want to use it here so that I could demonstrate how I would build a lite version. As such, I skipped providing tests for BaseResource as it would likely be replaced with something like ActiveResource.

### UI
We would need to add a mobile layout. I would also work the visuals of the 7 day forecast to have a more intuitive bar design. I did some normalization of the data, but it can use further improvement.

Leveraging CSS for conditional rendering can be more performant while also improving caching statistics, but it can also lead to more difficult testing. Rails integration tests do not actually render the CSS, so you have to spin up full systems tests in order to test that your CSS is correctly hiding the elements when you want. There may be better techniques to avoid full system tests just for testing rendered CSS, but I don't currently know of any.

The headless-view-components gem is a work in progress. I haven't yet integrated a form builder, so I had to leverage helpers for generating the input field name and ID in the same manner as the rails form builders. This will be improved so that building a form reads as more vanilla rails.

### Rubocop
The default rails-omakase gem lays a good baseline for rubocop. However, it forgoes any indentation decisions. A production app should provide more concrete styling.