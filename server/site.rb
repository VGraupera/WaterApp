require 'open-uri'
require 'xmlsimple'

class Site < SourceAdapter
  def initialize(source,credential)
    super(source,credential)
  end

  # this is a handy function to extract key-value pairs from a complex nested hash (hash of arrays and hashes such as is returned by
  # many web services)
  def extract_keyvalues(v)
  
    result={}
    if v.is_a?(Hash)

      v.each do |key,value|
        if value.is_a?(String)
          result[key]=value
        elsif value.is_a?(Array) and value.size==1 and value[0].is_a?(String)
          result[key]=value[0]
        else
          temp=extract_keyvalues(value)
          temp.keys.each do |x|
            result[x]=temp[x]
          end
        end
      end
    elsif v.is_a?(Array)
        v.each do |item|
          if item.is_a?(Hash) or item.is_a?(Array)
            temp=extract_keyvalues(item)
            temp.keys.each do |x|
              result[x]=temp[x]
            end
          end
        end
    end
    p "Returning result: #{result.inspect.to_s}"

    result
  end
 
  def query(conditions=nil)
    # use web service at http://qwwebservices.usgs.gov/technical-documentation.html#DOMAIN
    # for example: http://qwwebservices.usgs.gov/Station/search?bBox=-122.1,36.9,-121.9,37.1
    @radius=conditions[:radius] if conditions
    @radius||=0.1
    @lat=conditions[:lat] if conditions
    @lat||=37.33
    @long=conditions[:long] if conditions
    @long||=-122.04

    base_url="http://qwwebservices.usgs.gov/Station/search"
    p "Base URL #{base_url}"
    url=base_url+"?bBox=#{@long-@radius},#{@lat-@radius},#{@long+@radius},#{@lat+@radius}"
    puts "Opening #{url}"
    begin 
      response=open(url)
    rescue Exception=>e
      puts "Error opening: e.inspect.to_s"
    end
    begin 
      xmlresult=XmlSimple.xml_in(response.read)
    rescue Exception=>e
      puts "Error parsing: #{e.inspect.to_s}"
    end      

    @result={}  
    org=xmlresult["Organization"]
    p "Org: #{org[0].inspect.to_s}"
    org[0]["MonitoringLocation"].each do |loc|
      begin 
        puts "Site: #{loc.inspect.to_s}"
        puts "Site name: #{loc['MonitoringLocationIdentity'][0]['MonitoringLocationIdentifier']}"
        @result[loc['MonitoringLocationIdentity'][0]['MonitoringLocationIdentifier'][0]]=extract_keyvalues(loc)
      rescue
        puts "Failure to access site"
      end
    end
    p "Final result: #{@result.inspect.to_s}"

    @result
  end

  def sync
    p "@result in sync method: #{@result.inspect.to_s}"
    # TODO: write code here that converts the data you got back from query into an @result object
    # where @result is a hash of hashes,  each array item representing an object
    # for example: @result={"1"=>{"name"=>"Acme","industry"=>"Electronics"},"2"=>{"name"=>"Best","industry"=>"Software"}}
    # if you have such a hash of hashes, then you can just call "super" as shown below
    e=super # this creates object value triples from an @result variable that contains a hash of hashes 
    p "Error #{e.inspect.to_s}"
  end
 
  def create(name_value_list,blob=nil)
    #TODO: write some code here
    # the backend application will provide the object hash key and corresponding value
    raise "Please provide some code to create a single object in the backend application using the hash values in name_value_list"
  end
 
  def update(name_value_list)
    #TODO: write some code here
    # be sure to have a hash key and value for "object"
    raise "Please provide some code to update a single object in the backend application using the hash values in name_value_list"
  end
 
  def delete(name_value_list)
    #TODO: write some code here if applicable
    # be sure to have a hash key and value for "object"
    # for now, we'll say that its OK to not have a delete operation
    # raise "Please provide some code to delete a single object in the backend application using the hash values in name_value_list"
  end
 
  def logoff
    #TODO: write some code here if applicable
    # no need to do a raise here
  end
end 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
