import pika
import time
import os

# RabbitMQ connection parameters
RABBITMQ_HOST = os.getenv('RABBITMQ_HOST', 'localhost')
QUEUE_NAME = 'task_queue'

def main():
    print(f"[*] Connecting to RabbitMQ at {RABBITMQ_HOST}...")
    
    # Simple connection with retries
    connection = None
    while not connection:
        try:
            connection = pika.BlockingConnection(pika.ConnectionParameters(host=RABBITMQ_HOST))
        except Exception as e:
            print(f"Waiting for RabbitMQ... {e}")
            time.sleep(5)

    channel = connection.channel()
    channel.queue_declare(queue=QUEUE_NAME, durable=True)

    def callback(ch, method, properties, body):
        print(f" [x] Alınan görev: {body.decode()}")
        # Simüle edilen iş yükü
        time.sleep(0.1) 
        print(" [x] Görev tamamlandı.")
        ch.basic_ack(delivery_tag=method.delivery_tag)

    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(queue=QUEUE_NAME, on_message_callback=callback)

    print(' [*] Mesajlar bekleniyor. Çıkmak için CTRL+C')
    channel.start_consuming()

if __name__ == '__main__':
    main()
