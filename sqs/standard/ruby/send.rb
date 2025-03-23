require 'aws-sdk-sqs'

client = Aws::SQS::Client.new

queue_url="https://sqs.eu-west-3.amazonaws.com/783764602222/sqs-standard-MyQueue-fnJUkYZIl490"

resp = client.send_message({
  queue_url: queue_url,
  message_body: "Hello Ruby!",
  delay_seconds: 1,
  message_attributes: {
    "Fruit" => {
      string_value: "Apple",
      data_type: "String"
    }
  }
})