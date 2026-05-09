
  
    Bonus
    Network policies
  
  
    Five policies that implement a default-deny then explicit-allow model. The key goal: frontend pods cannot reach MongoDB directly — only the API can. This is the classic defense-in-depth pattern for 3-tier apps.
    
    Important: Minikube's default CNI (kindnet) does NOT enforce NetworkPolicies. Start Minikube with --cni=calico to enforce them.
  
  Start Minikube with: minikube start --driver=docker --memory=4096 --cpus=2 --cni=calico for NetworkPolicy enforcement.

  
    
      k8s/network-policies/network-policies.yaml
       Copy
    
    # 1. Default-deny all ingress in the namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: todo-app
spec:
  podSelector: {}
  policyTypes:
    - Ingress
---
# 2. Allow only API pods to reach MongoDB on 27017
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-to-db
  namespace: todo-app
spec:
  podSelector:
    matchLabels:
      app: mongodb
      tier: database
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: todo-api
              tier: backend
      ports:
        - protocol: TCP
          port: 27017
---
# 3. Allow frontend pods and NodePort traffic to reach the API
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
  namespace: todo-app
spec:
  podSelector:
    matchLabels:
      app: todo-api
      tier: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: todo-frontend
              tier: frontend
      ports:
        - protocol: TCP
          port: 8080
    - from: []
      ports:
        - protocol: TCP
          port: 8080
---
# 4. Allow external browser traffic to reach the frontend
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external-to-frontend
  namespace: todo-app
spec:
  podSelector:
    matchLabels:
      app: todo-frontend
      tier: frontend
  policyTypes:
    - Ingress
  ingress:
    - from: []
      ports:
        - protocol: TCP
          port: 8080
---
# 5. Explicit belt-and-suspenders: deny frontend -> db
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-frontend-to-db
  namespace: todo-app
spec:
  podSelector:
    matchLabels:
      app: mongodb
      tier: database
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: todo-api
              tier: backend
      ports:
        - protocol: TCP
          port: 27017
  
