require 'net/http'
require 'uri'
require 'json'

class ServelConsulta
  def initialize (appId, fid, rut)
    @appId = appId
    @fid = fid
    @rut = rut
  end

  def httpquery (uri, body_query, header)
    http = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https')
    request = Net::HTTP::Post.new(uri, header)
    request.body = body_query
    response = http.request(request)
    return response
  end

  def consulta1
    json_1 = { locale: 'en', digest: '', checkin: { iosbuild: { model: 'iPhone7,2', os_version: 'IOS_12.4.8' }, last_checkin_msec: 0, user_number: 0, type: 2 }, time_zone: 'America/Santiago', user_serial_number: 0, id: 0, version: 2, security_token: 0, fragment: 0 }
    uri_1 = URI('https://device-provisioning.googleapis.com/checkin')
    header1 = {
      'Content-Type' => 'application/json',
      'accept' => '*/*',
      'accept-language' => 'en-us',
      'User-Agent' => 'servelapp2020/1.20.17 CFNetwork/978.0.7 Darwin/18.7.0',
    }
    @response1 = httpquery(uri_1, json_1.to_json, header1)
    @response1_json = JSON.parse(@response1.body)
  end

  def consulta2
    json_2 = { appId: @appId, fid: @fid, authVersion: 'FIS_v2', sdkVersion: 'i:1.1.0' }
    uri_2 = URI('https://firebaseinstallations.googleapis.com/v1/projects/servelciudadano/installations/')
    header2 = {
      'Content-Type' => 'application/json',
      'accept' => '*/*',
      'x-firebase-client' => 'apple-sdk/18A390 fire-analytics/6.2.2 fire-fcm/4.2.1 fire-iid/4.3.1 fire-install/1.1.0 fire-ios/6.6.1 swift/true xcode/12A7300',
      'x-firebase-client-log-type' => '3',
      'x-ios-bundle-identifier' => 'com.Adexus.ServelCiudadano',
      'x-goog-api-key' => 'AIzaSyB2X9DSkjsyoQjEkoHjDFj5z1Zs6DXUgAc',
      'accept-language' => 'en-us',
      'User-Agent' => 'servelapp2020/1.20.17 CFNetwork/978.0.7 Darwin/18.7.0',
    }

    @response2 = httpquery(uri_2, json_2.to_json, header2)
    @response2_json = JSON.parse(@response2.body)
  end

  def consulta3
    consulta1
    consulta2
    uri_3 = URI('https://fcmtoken.googleapis.com/register')
    header3 = {
      'content-type' => 'application/x-www-form-urlencoded',
      'accept' => '*/*',
      'x-firebase-client' => 'apple-sdk/18A390 fire-analytics/6.2.2 fire-fcm/4.2.1 fire-iid/4.3.1 fire-install/1.1.0 fire-ios/6.6.1 swift/true xcode/12A7300',
      'authorization' => "AidLogin #{@response1_json['android_id']}:#{@response1_json['security_token']}",
      'x-firebase-client-log-type' => '1',
      'accept-language' => 'en-us',
      'app' => 'com.Adexus.ServelCiudadano',
      'user-agent' => 'servelapp2020/1.20.17 CFNetwork/978.0.7 Darwin/18.7.0',
      'info' => @response1_json["version_info"],
      'x-goog-firebase-installations-auth' => @response2_json["authToken"]["token"],
    }

    params = {
      'X-osv' => '12.4.8',
      'device' => @response1_json['android_id'],
      'X-scope' => '*',
      'plat' => '2',
      'app' => 'com.Adexus.ServelCiudadano',
      'app_ver' => '1.20.17',
      'X-cliv' => 'fiid-4.2.1',
      'sender' => '507517598050',
      'X-subtype' => '507517598050',
      'appid' => @response2_json['fid'],
      'gmp_app_id' => @appId,
    }

    @response3 = httpquery(uri_3, URI.encode_www_form(params), header3)
    @token_servel = @response3.body
    @token_servel = @token_servel.split('=')
  end

  def consulta4
    consulta3
    uri_4 = URI("https://apiapp.servelelecciones.cl/ServelCiudadanoBackend/api/auth/getToken")
    json_4 = { rut: @rut, deviceToken: @token_servel[1] }

    header4 = {
      'accept' => 'application/json, text/plain, */*',
      'content-type' => 'application/json',
      'user-agent' => 'Mozilla/5.0 (iPhone; CPU OS 12_4.8 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/12.4.8 Mobile/10A5355d Safari/8536.25',
      'accept-language' => 'en-us',
    }

    @response4 = httpquery(uri_4, json_4.to_json, header4)
    @response4_json = JSON.parse(@response4.body)
  end

  def consultaServel
    consulta4
    uri_5 = URI('https://apiapp.servelelecciones.cl/ServelCiudadanoBackend/api/private/CiudadanoRestService/CiudadanoInfo')
    json_5 = { timestamp: 0 }

    header5 = {
      'accept' => 'application/json, text/plain, */*',
      'content-type' => 'application/json',
      'user-agent' => 'Mozilla/5.0 (iPhone; CPU OS 12_4.8 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/12.4.8 Mobile/10A5355d Safari/8536.25',
      'accept-language' => 'en-us',
      'authorization' => "Bearer #{@response4_json['token']}",
    }

    response_servel = httpquery(uri_5, json_5.to_json, header5)
    response_servel_json = JSON.parse(response_servel.body)
    return response_servel_json["ciudadano"]
  end
end
