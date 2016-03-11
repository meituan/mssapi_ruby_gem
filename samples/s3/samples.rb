require 'mss-sdk'

s3 = MSS::S3.new({
    :s3_endpoint => 'mtmss.com',
    :use_ssl => false,
    :s3_force_path_style => true,
    :access_key_id => '',
    :secret_access_key => ''})

bucket = s3.buckets['testonly']
if bucket.exists?
  bucket.clear!
  bucket.delete
end
bucket = s3.buckets.create('testonly')
puts "Create bucket succ:" + bucket.name

s3.buckets.each do |bucket|
  puts "List buckets:" + bucket.name
end

puts "Before set public read, acl:"
puts bucket.acl
bucket.set_acl_public_read
puts "After set public read, acl:"
puts bucket.acl
bucket.set_acl_private
puts "After set private read, acl:"
puts bucket.acl

object_name = 'Hello!'
object_content = 'Word!'
bucket.objects[object_name].write(object_content)
puts "Upload succ:" + object_name

puts "Download succ:" + object_name
puts bucket.objects[object_name].read

File.open('/tmp/s3.rb.test.output', 'wb') do |file|
  bucket.objects[object_name].read do |chunk|
    file.write(chunk)
  end
end
puts "Download to file succ:" + object_name

temp_url_for_read = bucket.objects[object_name].url_for(:read, {:expire => 3600})
puts temp_url_for_read

upload = bucket.objects["Hello美团云！"].multipart_upload
upload.add_part("a" * 5242880)
upload.add_part("b" * 2097152)
upload.complete()
puts "Multipart upload succ, upload id:" + upload.id

