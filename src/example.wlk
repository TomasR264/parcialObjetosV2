class Mensaje{
	var usuarioQueLoEnvio
	var contenido
	
	method pesoMensaje() = 5 * contenido.pesoContenido() * 1.3
	
	method contieneTextoBuscado(textoBuscado) = self.esElNombreDelRemitente(textoBuscado) or contenido.contieneTextoBuscado(textoBuscado)
	
	method esElNombreDelRemitente(textoBuscado) = usuarioQueLoEnvio.esSuNombre(textoBuscado)
	
    

}

//// CONTENIDOS

class Contenido{
	method contieneTexto(textoBuscado) = false
}

class Texto inherits Contenido{
	var texto
	
	method pesoContenido() = texto.size()
	
	override method contieneTexto(textoBuscado) = texto.contains(textoBuscado)
}

class Audio inherits Contenido{
	var duracionEnSegundos
	
	method pesoContenido() = duracionEnSegundos * 1.2
	
	
}

class Imagen inherits Contenido{
	var alto
	var ancho
	var compresion
	
	method pesoContenido() = compresion.cantPixelesFinal(alto * ancho) * 2
}

object compresionOriginal{
	method cantPixelesFinal(cantPixeles) = cantPixeles
}

class CompresionVariable{
	var porcentajeCompresion
	
	
	method cantPixelesFinal(cantPixeles) = cantPixeles * porcentajeCompresion
}

object compresionMaxima{
	method cantPixelesFinal(cantPixeles) = 10000.min(cantPixeles)
}

class GIF inherits Imagen{
	var cantCuadros
	
	method cantPixelesFinal(cantPixeles) = cantPixeles * cantCuadros
	
	
}

class Contacto{
	var usuario
	
	method pesoContenido() = 3
}


class Notificacion{
	var leida
	var chatOrigen
	
	method esDeEseChat(chat) = chatOrigen == chat

    method serLeida(){
    	leida = true
    }
    
    method marcarseComoLeida(chat){
    	if(self.esDeEseChat(chat)){
    		self.serLeida()
    	}
    }
    
    method noEstaLeida() = not(leida)
}

/// CHATS

class Chat{
	var participantes = []
	
	
	method enviarMensaje(mensaje,usuario){
		if(self.restriccionPremium(usuario,self.cantMensajes(),mensaje) and self.restriccionNormal(usuario,mensaje)){
			self.enviarMensajeAParticipantes(mensaje)
			self.notificarParticipantes(new Notificacion(leida = false,chatOrigen = self))
		}
		else{
			self.error("No se puede enviar el mensaje")
		}
		
	}
	
	method elUsuarioEstaEntreLosParticipantes(usuario) = participantes.contains(usuario)
	method losParticipantesTienenEspacio(mensaje) = participantes.all({unParticipante => unParticipante.tieneEspacio(mensaje)})
    method enviarMensajeAParticipantes(mensaje) = participantes.forEach({unParticipante => unParticipante.recibirMensaje(mensaje)})
    
    method restriccionNormal(usuario,mensaje) = self.elUsuarioEstaEntreLosParticipantes(usuario) and self.losParticipantesTienenEspacio(mensaje)
    
    
    method agregarIntegrante(nuevoParticipante){
    	participantes.add(nuevoParticipante)
    }
    
    method removerIntegrante(participante){
    	participantes.remove(participante)
    }
    
    method cantMensajes() = participantes.first().cantMensajes()
    
    method restriccionPremium(usuario,cantMensajes,mensaje) = true


    method pesoChat() = participantes.sum({unParticipante => unParticipante.pesoDeMensajes()})
    
    method contieneElTextoBuscado(textoBuscado) = participantes.any({unParticipante => unParticipante.susMensajesContienenTextoBuscado(textoBuscado)})

    method elMasPesado() = participantes.first().elMasPesado()
    
    method notificarParticipantes(notificacion) = participantes.forEach({unParticipante => unParticipante.recibirNotificacion(notificacion)})
    

}


/// CHATS PREMIUM


class ChatPremium inherits Chat{
	var restriccion
	var creadorDelChat
	
	override method restriccionPremium(usuario,cantMensajes,mensaje) = restriccion.loPermite(usuario,creadorDelChat,cantMensajes,mensaje)
	
	method cambiarRestriccion(nuevaRestriccion){
		restriccion = nuevaRestriccion
	}
}


object difusion{
	method loPermite(usuario,creadorDelChat,cantMensajes,mensaje) = usuario == creadorDelChat
}

class Restringido{
	var limite
	
	method loPermite(usuario,creadorDelChat,cantMensajes,mensaje) = limite > cantMensajes
}


class Ahorro{
	var pesoMaximo
	
	method loPermite(usuario,creadorDelChat,cantMensajes,mensaje) = mensaje.pesoMensaje() < pesoMaximo
}









/// USUARIOS

class Usuario{
	var mensajes = []
	var chats = []
	var notificaciones = []
	var nombre
 	var espacioLibre
	
	method tieneEspacio(mensaje) = espacioLibre > mensaje.pesoMensaje()
	
	method recibirMensaje(mensaje){
		mensajes.add(mensaje)
		espacioLibre -= mensaje.pesoMensaje()
	}
	
	method tieneElMensaje(mensaje) = mensajes.contains(mensaje)
	
	method cantMensajes() = mensajes.size()
	
	method pesoMensajes() = mensajes.sum({unMensaje => unMensaje.pesoMensaje()})
	
	method enviarMensaje(mensaje,chat) = chat.enviarMensaje(mensaje,self) 

    method buscarTexto(textoBuscado) = chats.filter({unChat => unChat.contieneElTextoBuscado(textoBuscado)})
    
    
    method susMensajesContienenTextoBuscado(textoBuscado) = mensajes.any({unMensaje => unMensaje.contieneTextoBuscado(textoBuscado)})
    
    
    method esSuNombre(textoBuscado) = nombre.contains(textoBuscado)
    
    method losMensajesMasPesados() = chats.map({unChat => unChat.elMasPesado()})
    
    method elMasPesado() = mensajes.max({unMensaje => unMensaje.pesoMensaje()})
    
    method recibirNotificacion(notificacion) = notificaciones.add(notificacion)

    method leerChat(chat) = notificaciones.forEach({unaNotificacion => unaNotificacion.marcarseComoLeida()})

    method notificacionesNoLeidas() = notificaciones.filter({unaNotificacion => unaNotificacion.noEstaLeida()})

}











