import pika
import sys

# Change this to the RabbitMQ IP if running locally against a remote cluster
# For Minikube port-forward: localhost
RABBITMQ_HOST = 'localhost'
QUEUE_NAME = 'task_queue'
NUM_MESSAGES = 10000

def main():
    try:
        connection = pika.BlockingConnection(pika.ConnectionParameters(host=RABBITMQ_HOST))
        channel = connection.channel()

        channel.queue_declare(queue=QUEUE_NAME, durable=True)

        print(f"[*] Kuyruğa {NUM_MESSAGES} mesaj gönderiliyor...")

        for i in range(NUM_MESSAGES):
            message = f"Görev #{i}"
            channel.basic_publish(
                exchange='',
                routing_key=QUEUE_NAME,
                body=message,
                properties=pika.BasicProperties(
                    delivery_mode=2,  # make message persistent
                ))
            if i % 1000 == 0:
                print(f" [>] {i} mesaj gönderildi...")

        print(f" [x] Toplam {NUM_MESSAGES} mesaj gönderildi!")
        connection.close()
    except Exception as e:
        print(f"Hata: {e}")
        print("İpucu: 'kubectl port-forward service/rabbitmq 5672:5672' komutunun çalıştığından emin olun.")

if __name__ == '__main__':
    main()
