# RabbitMQ & KEDA Demonstration (Event-Driven Autoscaling)

This directory contains a demonstration of event-driven autoscaling in Kubernetes using **KEDA (Kubernetes Event-driven Autoscaling)** and **RabbitMQ**.

## 🚀 Overview

The goal of this demo is to show how Kubernetes can scale worker pods dynamically from **0 to 30** based on the number of messages waiting in a RabbitMQ queue, and then scale back down to zero when the work is finished.

### Components:
*   **RabbitMQ:** The message broker that holds tasks in a queue.
*   **Worker:** A Python-based consumer that processes messages.
*   **Producer:** A script to inject load (messages) into the system.
*   **KEDA:** The autoscaler that monitors RabbitMQ and scales the Worker deployment.

## 📖 Getting Started

For a complete, step-by-step guide on how to set up and run this demonstration, please refer to the detailed walkthrough:

👉 **[Detailed Walkthrough: KEDA & RabbitMQ](./walkthrough.md)**

## 📂 Directory Structure

*   `k8s/`: Kubernetes manifests for RabbitMQ, Workers, and KEDA configurations.
*   `worker/`: Source code and Dockerfile for the message consumer.
*   `producer.py`: Python script to send test messages.
*   `setup.ps1`: Automated setup script for Windows/PowerShell.
