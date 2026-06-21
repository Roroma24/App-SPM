import bcrypt

# 1. Coloca aquí la contraseña en texto plano que deseas cifrar
contrasenia_plana = "Saltamontes71"

print(f'Cifrando contraseña: "{contrasenia_plana}"...\n')

# 2. Generamos el "salt" con 12 rondas de complejidad 
# (para igualar el '$12$' de tu estructura original de MongoDB)
salt = bcrypt.gensalt(rounds=12)

# 3. Ciframos la contraseña. 
# Bcrypt en Python requiere que los strings estén codificados en bytes (.encode('utf-8'))
contrasenia_bytes = contrasenia_plana.encode('utf-8')
hash_bytes = bcrypt.hashpw(contrasenia_bytes, salt)

# 4. Convertimos el resultado de bytes de vuelta a un string normal para leerlo
hash_final = hash_bytes.decode('utf-8')

print("================ CONTRASEÑA CIFRADA ================")
print(hash_final)
print("====================================================")
print("\nCopia el texto de arriba y pégalo en el campo 'password' de tu MongoDB.")