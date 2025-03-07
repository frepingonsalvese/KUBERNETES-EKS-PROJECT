# KUBERNETES-EKS-PROJECT
# Deploying Multiple Web Applications on AWS EKS with Nginx Ingress

## **Project Overview**
This project demonstrates how to deploy multiple web applications (Nginx, Apache, and a Game app) on an **Amazon EKS** cluster using **Kubernetes** and manage traffic using **Nginx Ingress Controller**. The goal is to serve different applications at different paths using a single Load Balancer.

## **Prerequisites**
Before starting, ensure you have the following installed on your local system:
- **kubectl** – Kubernetes command-line tool
- **AWS CLI** – AWS command-line interface
- **eksctl** – Command-line tool to create and manage EKS clusters
- **Helm** – Kubernetes package manager

## **Step 1: Creating an EKS Cluster**
To set up an EKS cluster, run the following command:
```sh
eksctl create cluster \
  --name my-cluster \
  --region us-east-1 \
  --nodegroup-name my-nodes \
  --node-type t3.medium \
  --nodes 2
```
This will create a managed EKS cluster with two worker nodes.

## **Step 2: Installing Nginx Ingress Controller**
Nginx Ingress Controller is required to route traffic properly to our applications.
```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
```
This creates a **Classic Load Balancer (CLB)** to handle external traffic.

## **Step 3: Deploying Applications**
We deploy three applications: **Nginx, Apache, and a 2048 Game App**.

### **Nginx Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
```

### **Nginx Service**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: default
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
```

### **Apache Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-deployment
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: apache
  template:
    metadata:
      labels:
        app: apache
    spec:
      containers:
      - name: my-apache-site
        image: httpd:2.4
        ports:
        - containerPort: 80
```

### **Apache Service**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: apache-service
  namespace: default
spec:
  selector:
    app: apache
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
```

### **Game App Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: game-deployment
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: game
  template:
    metadata:
      labels:
        app: game
    spec:
      containers:
      - name: game-container
        image: suhlig/2048-game:latest
        ports:
        - containerPort: 8080
```

### **Game Service**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: game-service
  namespace: default
spec:
  selector:
    app: game
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  type: ClusterIP
```

## **Step 4: Configuring Ingress**
The Ingress Controller will route requests to different applications based on the path.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-apps-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /nginx
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
      - path: /apache
        pathType: Prefix
        backend:
          service:
            name: apache-service
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: game-service
            port:
              number: 8080
```

This configuration ensures:
- `http://<LB-DNS>/nginx` → Routes to the **Nginx service**
- `http://<LB-DNS>/apache` → Routes to the **Apache service**
- `http://<LB-DNS>/` → Routes to the **Game app**

## **Step 5: Applying the Configuration**
```sh
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
kubectl apply -f apache-deployment.yaml
kubectl apply -f apache-service.yaml
kubectl apply -f game-deployment.yaml
kubectl apply -f game-service.yaml
kubectl apply -f ingress.yaml
```

## **Step 6: Accessing the Applications**
Find the **Load Balancer DNS** by running:
```sh
kubectl get ingress web-apps-ingress
```
Example output:
```
NAME               HOSTS   ADDRESS                                                                       PORTS   AGE
web-apps-ingress   *       a1414c21f09194b69b5035bf95937e25-678639043.us-east-1.elb.amazonaws.com        80      5m
```
Now, you can access your applications using:
- **Game App:** `http://a1414c21f09194b69b5035bf95937e25-123456789.us-east-1.elb.amazonaws.com/`

  ![image](https://github.com/user-attachments/assets/a649e57f-157b-4596-b6ce-91dc72c4943e)

- **Nginx:** `http://a1414c21f09194b69b5035bf95937e25-123456789.us-east-1.elb.amazonaws.com/nginx`

  ![Screenshot from 2025-03-07 17-01-50](https://github.com/user-attachments/assets/b36d1d77-850f-47ae-9463-250a684ff14d)

- **Apache:** `http://a1414c21f09194b69b5035bf95937e25-123456789.us-east-1.elb.amazonaws.com/apache`

  ![Screenshot from 2025-03-07 17-02-01](https://github.com/user-attachments/assets/a04ab99d-f493-4cb8-84aa-d6e06fc44aff)



## **Conclusion**
This project demonstrates how to deploy multiple applications on an **EKS Cluster** using **Kubernetes, Helm, and Nginx Ingress Controller**. The setup effectively routes traffic using a single Load Balancer, reducing costs and improving scalability.

