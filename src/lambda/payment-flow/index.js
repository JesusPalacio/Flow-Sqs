require('dotenv').config();
const AWS = require('aws-sdk');
const dynamo = new AWS.DynamoDB.DocumentClient();
const sqs = new AWS.SQS();

exports.handler = async (event) => {
  console.log("Evento recibido:", JSON.stringify(event, null, 2));

  for (const record of event.Records) {
    const message = JSON.parse(record.body);

    const data = message.data || message;
    const { traceId, userId, service, status } = data;
    const email = message.email;

    console.log(`Procesando pago: traceId=${traceId}, status=${status}`);

    if (!traceId || !status) {
      console.warn("⚠️ Mensaje ignorado por formato inválido:", message);
      continue;
    }

    // Guardar en DynamoDB
    await dynamo.put({
      TableName: process.env.PAYMENT_TABLE,
      Item: {
        traceId,
        userId,
        service,
        status,
        timestamp: new Date().toISOString()
      }
    }).promise();

    console.log(`💾 Estado ${status} guardado para ${traceId}`);

    // Enviar notificación solo si el pago terminó o falló
    if (status === "FINISH" || status === "FAILED") {
      const notification = {
        type: "PAYMENT.STATUS",
        email,
        data: {
          traceId,
          userId,
          service: {
            servicio: service?.servicio || "Servicio desconocido",
            plan: service?.plan || ""
          },
          status
        }
      };
      console.log("🔍 Service extraído:", JSON.stringify(service, null, 2));
      console.log("📤 Enviando notificación a SQS:", notification);

      await sqs.sendMessage({
        QueueUrl: process.env.NOTIFICATION_QUEUE_URL,
        MessageBody: JSON.stringify(notification)
      }).promise();

      console.log("✅ Notificación enviada correctamente");
    }
  }

  return { statusCode: 200, body: "Flujo procesado correctamente" };
};


if (require.main === module) {
  const event = require('../../../event.json');
  exports.handler(event)
    .then(res => console.log("✅ Resultado:", res))
    .catch(err => console.error("❌ Error:", err));
}
