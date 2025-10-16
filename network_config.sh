#!/bin/bash

echo "Выберите тип конфигурации сети:"
echo "1) dhcp"
echo "2) static"
read -p "Введите ваш выбор (1 или 2): " choice

if [ "$choice" = "1" ] || [ "$choice" = "dhcp" ]; then
    echo "Выбран режим DHCP"
    
elif [ "$choice" = "2" ] || [ "$choice" = "static" ]; then
    echo "Выбран режим Static"
    
    # Запрос IP-адреса
    read -p "Введите IP-адрес: " ip_address
    
    # Проверка корректности IP-адреса
    if ! echo "$ip_address" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
        echo "некорректные данные: IP-адрес"
        exit 1
    fi
    
    # Проверка каждого октета IP-адреса
    IFS='.' read -r -a ip_octets <<< "$ip_address"
    for octet in "${ip_octets[@]}"; do
        if [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ]; then
            echo "некорректные данные: IP-адрес (октет $octet недопустим)"
            exit 1
        fi
    done
    
    # Запрос маски сети
    echo "Формат маски:"
    echo "1) В формате CIDR (например, 24)"
    echo "2) В формате dotted decimal (например, 255.255.255.0)"
    read -p "Выберите формат маски (1 или 2): " mask_format
    
    if [ "$mask_format" = "1" ]; then
        read -p "Введите маску в формате CIDR (0-32): " cidr_mask
        
        # Проверка корректности CIDR маски
        if ! [[ "$cidr_mask" =~ ^[0-9]+$ ]] || [ "$cidr_mask" -lt 0 ] || [ "$cidr_mask" -gt 32 ]; then
            echo "некорректные данные: маска сети CIDR"
            exit 1
        fi
        
        echo "Маска сети: /$cidr_mask"
        
    elif [ "$mask_format" = "2" ]; then
        read -p "Введите маску в формате dotted decimal: " subnet_mask
        
        # Проверка корректности маски подсети
        if ! echo "$subnet_mask" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
            echo "некорректные данные: маска сети"
            exit 1
        fi
        
        # Проверка каждого октета маски
        IFS='.' read -r -a mask_octets <<< "$subnet_mask"
        for octet in "${mask_octets[@]}"; do
            if [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ]; then
                echo "некорректные данные: маска сети (октет $octet недопустим)"
                exit 1
            fi
        done
        
        echo "Маска сети: $subnet_mask"
        
    else
        echo "некорректные данные: формат маски"
        exit 1
    fi
    
    echo "Конфигурация успешно применена:"
    echo "IP: $ip_address"
    if [ "$mask_format" = "1" ]; then
        echo "Маска: /$cidr_mask"
    else
        echo "Маска: $subnet_mask"
    fi
    
else
    echo "некорректные данные: выбор конфигурации"
    exit 1
fi
