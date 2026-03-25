# ArgoCD & GitOps Demonstration

This directory contains a demonstration of **GitOps** principles using **ArgoCD** to manage application deployments in Kubernetes.

## 🚀 Overview

The goal of this demo is to showcase how a Git repository can serve as the "Single Source of Truth" for your infrastructure, enabling automated deployments, self-healing, and easy rollbacks.

### Features Demonstrated:
*   **Disaster Recovery (Self-Healing):** Automatically detecting and fixing manual changes (drift) in the cluster.
*   **GitOps Workflow:** Deploying updates simply by pushing changes to a Git repository.
*   **Version Rollbacks:** Reverting to previous stable states by rolling back commits in Git.

## 📖 Getting Started

For a complete, step-by-step guide on how to set up and run this demonstration from scratch, please refer to the detailed walkthrough:

👉 **[Detailed Walkthrough: ArgoCD & GitOps](./walkthrough.md)**

## 📂 Directory Structure

*   `app/`: A simple web application with multiple versions (v1/Blue, v2/Green).
*   `gitops/`: Kubernetes manifests (Deployment, Service) tracked by ArgoCD.
*   `setup.ps1`: Automated setup script for Windows/PowerShell.
