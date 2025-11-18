// Script para crear una reserva de prueba
// Ejecutar con: node scripts/create_test_reservation.js

const https = require('https');

const BASE_URL = 'https://paxtech.azurewebsites.net/api/v1';
const JWT_TOKEN = 'eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJzYWxvbnNwYW1hcmlhQGdtYWlsLmNvbSIsImlhdCI6MTc2MzQ4OTQ1MSwiZXhwIjoxNzY0MDk0MjUxfQ.wxSSn7R5qOzFcNhc_SX5z5AIvXjEavQXHjfU_0tty5Bm20apTppa3dHJcy7QdAxQ'; // Reemplazar con tu token JWT

// Valores de prueba
const clientId = 2;
const providerId = 8;
const serviceId = 18;
const workerId = 24;
const timeSlotId = 53; // TimeSlot ya creado

// Fecha de hoy a las 15:00 (3:00 PM)
const today = new Date();
today.setHours(15, 0, 0, 0); // 15:00:00

// Obtener la duración del servicio desde la lista de servicios
function getServiceDuration(serviceId, callback) {
  const options = {
    hostname: 'paxtech.azurewebsites.net',
    path: '/api/v1/services', // Obtener todos los servicios
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${JWT_TOKEN}`,
      'Content-Type': 'application/json'
    }
  };

  const req = https.request(options, (res) => {
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    res.on('end', () => {
      if (res.statusCode === 200) {
        try {
          const services = JSON.parse(data);
          if (!Array.isArray(services)) {
            callback(new Error('La respuesta no es un array de servicios'));
            return;
          }
          
          // Buscar el servicio con el ID especificado
          const service = services.find(s => s.id === serviceId);
          
          if (!service) {
            callback(new Error(`No se encontró el servicio con ID ${serviceId}`));
            return;
          }
          
          if (!service.duration) {
            callback(new Error(`El servicio ${serviceId} no tiene duración definida`));
            return;
          }
          
          console.log(`📋 Servicio encontrado: ${service.name || 'Sin nombre'}`);
          callback(null, service.duration); // Duración en minutos
        } catch (e) {
          console.error('Error parseando respuesta:', data);
          callback(new Error(`Error parseando servicios: ${e.message}`));
        }
      } else {
        console.error('Respuesta del servidor:', data);
        callback(new Error(`Error obteniendo servicios: ${res.statusCode} - ${data}`));
      }
    });
  });

  req.on('error', (error) => {
    callback(error);
  });

  req.end();
}

// Crear TimeSlot
function createTimeSlot(startTime, duration, callback) {
  const endTime = new Date(startTime);
  endTime.setMinutes(endTime.getMinutes() + duration);

  // Formato exacto que pide la API
  const timeSlotData = {
    startTime: startTime.toISOString(), // Formato ISO: "2025-11-18T18:19:51.089Z"
    endTime: endTime.toISOString(),     // Formato ISO: "2025-11-18T18:19:51.089Z"
    status: true,                       // Por defecto: true
    type: "string"                      // Por defecto: "string"
  };
  
  console.log('📤 Enviando TimeSlot:', JSON.stringify(timeSlotData, null, 2));

  const options = {
    hostname: 'paxtech.azurewebsites.net',
    path: '/api/v1/time-slots',
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${JWT_TOKEN}`,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  };
  
  console.log('🔗 URL:', `https://${options.hostname}${options.path}`);
  console.log('🔑 Token usado:', JWT_TOKEN.substring(0, 30) + '...');

  const req = https.request(options, (res) => {
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    res.on('end', () => {
      if (res.statusCode === 200 || res.statusCode === 201) {
        try {
          const timeSlot = JSON.parse(data);
          console.log('📦 Respuesta TimeSlot:', JSON.stringify(timeSlot, null, 2));
          if (!timeSlot.id) {
            callback(new Error('TimeSlot creado pero no tiene ID en la respuesta'));
            return;
          }
          callback(null, timeSlot.id);
        } catch (e) {
          console.error('Error parseando TimeSlot:', data);
          callback(new Error(`Error parseando TimeSlot: ${e.message}`));
        }
      } else {
        console.error('❌ Error creando TimeSlot. Status:', res.statusCode);
        console.error('📥 Respuesta completa:', data || '(vacía)');
        console.error('📤 Datos enviados:', JSON.stringify(timeSlotData, null, 2));
        if (res.statusCode === 401) {
          console.error('⚠️  Error 401: Token no autorizado o expirado');
          console.error('💡 Verifica que el token JWT sea válido y no haya expirado');
          console.error('💡 El token debe tener permisos para crear TimeSlots');
        }
        callback(new Error(`Error creando TimeSlot: ${res.statusCode} - ${data || 'Sin respuesta'}`));
      }
    });
  });

  req.on('error', (error) => {
    console.error('❌ Error de red:', error.message);
    callback(error);
  });

  // Escribir el body del request
  const body = JSON.stringify(timeSlotData);
  console.log('📦 Body enviado:', body);
  req.write(body);
  req.end();
}

// Crear reserva usando reservationsDetails
function createReservation(clientId, providerId, serviceId, timeSlotId, workerId, callback) {
  const reservationData = {
    clientId: clientId,
    providerId: providerId,
    serviceId: serviceId,
    timeSlotId: timeSlotId,
    workerId: workerId
  };

  console.log('📤 Datos de reserva:', JSON.stringify(reservationData, null, 2));

  const options = {
    hostname: 'paxtech.azurewebsites.net',
    path: '/api/v1/reservationsDetails', // Endpoint correcto
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${JWT_TOKEN}`,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  };
  
  console.log('🔗 URL:', `https://${options.hostname}${options.path}`);

  const req = https.request(options, (res) => {
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    res.on('end', () => {
      if (res.statusCode === 200 || res.statusCode === 201) {
        try {
          const reservation = JSON.parse(data);
          callback(null, reservation);
        } catch (e) {
          console.error('Error parseando reserva:', data);
          callback(new Error(`Error parseando reserva: ${e.message}`));
        }
      } else {
        console.error('Error creando reserva. Status:', res.statusCode);
        console.error('Respuesta:', data);
        console.error('Datos enviados:', JSON.stringify(reservationData, null, 2));
        callback(new Error(`Error creando reserva: ${res.statusCode} - ${data}`));
      }
    });
  });

  req.on('error', (error) => {
    callback(error);
  });

  req.write(JSON.stringify(reservationData));
  req.end();
}

// Flujo principal
console.log('🚀 Creando reserva de prueba...');
console.log(`👤 Cliente: ${clientId}`);
console.log(`🏢 Proveedor: ${providerId}`);
console.log(`💇 Servicio: ${serviceId}`);
console.log(`👷 Trabajador: ${workerId}`);
console.log(`⏰ TimeSlot ID: ${timeSlotId} (ya creado)`);
console.log(`🔑 Token: ${JWT_TOKEN.substring(0, 20)}...`);

// Crear reserva directamente con el TimeSlot existente
console.log('\n📌 Creando reserva con TimeSlot ID existente...');
createReservation(clientId, providerId, serviceId, timeSlotId, workerId, (err, reservation) => {
  if (err) {
    console.error('❌ Error creando reserva:', err.message);
    return;
  }

  console.log('\n✅ ¡Reserva creada exitosamente!');
  console.log('📋 Reserva:', JSON.stringify(reservation, null, 2));
});

