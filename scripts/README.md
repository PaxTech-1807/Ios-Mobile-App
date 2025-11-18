# Scripts de Prueba

## create_test_reservation.js

Script para crear una reserva de prueba en el sistema.

### Uso:

1. **Instalar Node.js** (si no lo tienes instalado)

2. **Obtener tu JWT Token:**
   - Inicia sesión en la app
   - El token se guarda automáticamente en `shared_preferences`
   - O puedes obtenerlo del log de la app cuando haces login

3. **Editar el script:**
   - Abre `scripts/create_test_reservation.js`
   - Reemplaza `TU_TOKEN_AQUI` con tu token JWT real

4. **Ejecutar el script:**
   ```bash
   node scripts/create_test_reservation.js
   ```

### Valores de prueba configurados:
- **clientId**: 2
- **providerId**: 8
- **serviceId**: 18
- **workerId**: 24
- **Hora**: Hoy a las 15:00 (3:00 PM)
- **Duración**: Se calcula automáticamente según la duración del servicio

### Qué hace el script:
1. Obtiene la duración del servicio (serviceId: 18)
2. Crea un TimeSlot para hoy a las 15:00 con la duración calculada
3. Crea la reserva con todos los valores especificados

### Nota:
El script crea la reserva para **hoy** a las **15:00**. Si quieres cambiar la fecha/hora, edita la variable `today` en el script.

