require 'telegram/bot'
require './servel.rb'
# encoding: UTF-8

token = ENV['BOT_TOKEN_RUBY']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    data = message.text.split(" ")
    appId = '1:507517598050:ios:d03b8533eec1c345'
    fid = 'e7EncfKdiUWQttT04VCand'
    case data[0]
    when '/consultar'
      if data[1] != nil and data[1] =~ /\d/
        rut = data[1].split('-')
        dv = [*0..9,'K'][rut[0].to_s.reverse.chars.inject([0,0]){|(i,a),n|[i+1,a-n.to_i*(i%6+2)]}[1]%11]
        if rut[1].upcase == 'K'
            rut_v = 'K'
        else
            rut_v = rut[1].to_i
        end
        if dv != rut_v
            bot.api.send_message(chat_id: message.chat.id, text: "Rut no válido. Favor, ingresarlo siguendo el formato 12345678-9")
        else
            ser = ServelConsulta.new(appId,fid,rut[0])
            datos_servel = ser.consultaServel
            string_datos = "Datos del Servel: \n\n"
            string_datos += "Rut: #{datos_servel['rut']} \n"
            string_datos += "Nombre: #{datos_servel['nombre']} \n"
            string_datos += "Circunscripción electoral: #{datos_servel['circElectoral']} \n"
            string_datos += "Comuna: #{datos_servel['comuna']} \n"
            string_datos += "Provincia: #{datos_servel['provincia']} \n"
            string_datos += "Región: #{datos_servel['region']} \n"
            string_datos += "País: #{datos_servel['pais']} \n"
            string_datos += "Habilitado para sufragar: #{datos_servel['puedesufragar']}\n"
            if datos_servel['puedesufragar'] == "SI"
                string_datos += "Mesa: #{datos_servel['mesa']} \n"
                string_datos += "Local de votación: #{datos_servel['local']['nombre']} \n"
                string_datos += "Ubicación: #{datos_servel['local']['ubicacion']} \n"
                string_datos += "Vocal de mesa: #{datos_servel['esvocal']} \n"
                string_datos += "Miembro del colegio escrutador: #{datos_servel['esmiembro']} \n"
            end
            bot.api.send_message(chat_id: message.chat.id, text: string_datos)
            if datos_servel['puedesufragar'] == "SI"
                bot.api.send_location(chat_id: message.chat.id, latitude: datos_servel['local']['lat'], longitude: datos_servel['local']['lng'])
            end
        end
      else
          bot.api.send_message(chat_id: message.chat.id, text: "Rut inválido o no ingresado. Favor usar el formato 12345678-9")
      end
    when '/ayuda'
        bot.api.send_message(chat_id: message.chat.id, text: "Consulta con el comando /consultar RUT, sin puntos y con el dígito verificador separado de un guion.\nEjemplo: /consultar 12345678-9")
    when '/about'
        string_about = "Consulta Servel, un bot creado por Jorgicio. \n"
        string_about += "Si te gusta lo que hago, puedes visitar mi página web: www.jorgicio.net\n"
        string_about += "o puedes leerme en mi blog: http://blog.jorgicio.net\n"
        string_about += "También puedes seguirme en mi cuenta personal de Telegram: @jorgicio\n"
        string_about += "o seguirme en mis RRSS que están en mi página web."
        bot.api.send_message(chat_id: message.chat.id, text: string_about)
    end
  end
end
