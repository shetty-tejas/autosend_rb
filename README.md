# AutosendRb

A (hopefully, official soon) Ruby SDK for the AutoSend.com API, designed to be idiomatic, robust, and easy to use.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'autosend_rb'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install autosend_rb
```

## Configuration

Configure the gem with your API key. You can do this in an initializer (e.g., `config/initializers/autosend.rb` in Rails).

```ruby
AutosendRb.configure do |config|
  config.api_key = "your_api_key"
  # config.api_host = "https://api.autosend.com" # Optional, defaults to production
  # config.http_timeout = 10 # Optional, defaults to 10 seconds
end
```

## Usage

### Sending a Single Email

You can send an email using a clean, block-based syntax:

```ruby
response = AutosendRb::Mail.send do |email|
  email.from = { email: "sender@example.com", name: "Sender Name" }
  email.to = { email: "recipient@example.com", name: "Recipient Name" }
  email.subject = "Welcome to Autosend!"
  email.body = {
    html: "<h1>Hello, {{name}}!</h1><p>Welcome to our service.</p>",
    text: "Hello, {{name}}! Welcome to our service."
    # Alternatively, use a template ID
    # template_id: "template_12345"
  }
  
  # Dynamic data for template variables
  email.body.dynamic_data = { name: "John Doe" }
  
  # Attachments (File object, path string, or Hash with description)
  email.add_attachment("path/to/invoice.pdf")
  email.add_attachment({file: File.open("path/to/image.png"), description: "Product Image"})
  email.add_attachment({file: "https://example.com/document.jpeg", description: "Document"})
  email.add_attachment(File.open("path/to/terms.pdf"))
end

puts "Email sent! ID: #{response.email_id}"
```

### Sending Bulk Emails

Send the same email to multiple recipients with individual dynamic data:

```ruby
response = AutosendRb::Mail.bulk do |email|
  email.from = { email: "sender@example.com", name: "Sender Name" }
  email.subject = "Weekly Newsletter"
  email.body = {
    html: "<h1>Hello, {{name}}!</h1><p>Here is your weekly newsletter.</p>",
    text: "Hello, {{name}}! Here is your weekly newsletter."
    # Alternatively, use a template ID
    # template_id: "template_67890"
  }
  
  # Add recipients
  email.add_recipient(
    email: "alice@example.com", 
    name: "Alice", 
    dynamic_data: { name: "Alice" } 
  )
  
  email.add_recipient(
    email: "bob@example.com", 
    name: "Bob", 
    dynamic_data: { name: "Bob" } 
  )
end

puts "Batch ID: #{response.batch_id}"
puts "Success: #{response.success_count}, Failed: #{response.failed_count}"
```

### Using Request Objects

If you prefer building request objects manually:

```ruby
request = AutosendRb::Requests::SendEmail.new
request.from = { email: "sender@example.com" }
request.to = { email: "recipient@example.com" }
request.subject = "Manual Request"
request.body = { html: "<p>Content</p>" }

AutosendRb::Mail.send(request)
```

### Using Hash Payloads

Or, you can pass a Hash directly:

```ruby
payload = {
  from: { email: "sender@example.com" },
  to: { email: "recipient@example.com" },
  subject: "Hash Payload Request",
  html: "<p>Content</p>",
  text: "Content",
  attachments: [
    { file: "https://example.com/image.png", description: "An image" },
    { file: File.open("path/to/document.pdf"), description: "A document" }
  ]
}

AutosendRb::Mail.send(payload)
```

## Error Handling

The SDK raises specific errors for API failures:

*   `AutosendRb::BadRequestError` (400)
*   `AutosendRb::UnauthorizedError` (401)
*   `AutosendRb::PaymentRequiredError` (402)
*   `AutosendRb::ForbiddenError` (403)
*   `AutosendRb::NotFoundError` (404)
*   `AutosendRb::TooManyRequestsError` (429)
*   `AutosendRb::InternalServerErrorError` (500)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AutosendRb project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shetty-tejas/autosend_rb/blob/master/CODE_OF_CONDUCT.md).
