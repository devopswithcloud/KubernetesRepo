kubectl create cm literalcm --from-literal=Key1=Value1 --from-literal=Key2=Value2
kubectl create secret generic firstsecret --from-literal=password=india1234



#  echo -n 'password1234' | base64
# echo -n 'cGFzc3dvcmQxMjM0' | base64 --decode