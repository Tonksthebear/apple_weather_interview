# Weather App

## Design
- Vanilla Rails (HOTWire) + Tailwind
- Form built with accessibility in mind using a component library I'm working on [headless-component-rails](https://github.com/Tonksthebear/headless-components-rails) ([link to demo site](https://headless-components-rails.onrender.com))
- ActiveRecord-esque models leveraging a custom [BaseResource](./models/base_resource.rb)
- Leverage CSS instead of javascript and/or erb conditionals when rendering different states
  - `not-has-[a]:hidden` Only show a box with links when there are links
  - `data-[name='']:hidden peer-[:has(a)]:hidden` Only show a warning that the search didn't find anything if the peer does not have any links and if the search name is not nil

```erb
<%= render Headless::ButtonComponent.new(class: "group flex-shrink rounded-lg rounded-l-none border-none bg-white/5 py-1.5 px-3 text-sm/6 text-white focus:outline-none data-[focus]:outline-2 data-[focus]:-outline-offset-2 data-[focus]:outline-white/25 data-[hover]:bg-white/15 disabled:data-[hover]:bg-gray-800 disabled:cursor-not-allowed disabled:bg-gray-800",type: :submit, name: "commit", value: "Search", data: { disable_with: "Searching..." } ) do %>
  <%= heroicon "magnifying-glass-circle", class: "size-8 group-disabled:hidden" %>
  <%= heroicon "rocket-launch", class: "hidden size-8 animate-bounce group-disabled:block" %>
<% end %>
```
On the form-submit button, display the circle when it's clickable and the rocket ship when the form is busy


## Considerations
- In order to show that a page was cached, I had to disable [Turbo 8 prefetch](https://turbo.hotwired.dev/handbook/drive#prefetching-links-on-hover), otherwise the page would be cached before the link was clicked and would therefore always show the page as cached
- I skipped testing for custom associations becuase realistically we'd use a gem already battle tested like [ActiveResource](https://github.com/rails/activeresource) (discussed later)

## Production Considerations
- I built [BaseResource](./models/base_resource.rb) to mimic ActiveRecord in order to improve developer happiness when working with the API. The more rails-y, the better. I also built a light [association manager](./models/concerns/associations.rb). However, depending on if the production version would actually have a database, I would consider changing the DSL to differ more from ActiveRecord. It would be confusing to have an application that has true ActiveRecord and a pseudo version for REST APIs.
- I would consider using a more battle-tested gem like [ActiveResource](https://github.com/rails/activeresource) in a production app. A homegrown solution like mine is great for small scopes, but may become difficult to maintain as feature scope grows. I didn't want to use it here so that I could demonstrate how I would build a lite version.