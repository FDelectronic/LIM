#!/bin/bash
#? Linux installation manager  (LIM)
#* the_core_archlinux_instal  
loadkeys ru
setfont cyr-sun16
timedatectl set-ntp true
log_questioner (){ if [ $test_log == 0 ]; then echo "$log_txt = $questioner" >>arch_instal.log; fi }
log_program (){ if [ $test_log == 0 ]; then echo "  $log_txt = $program_status" >>arch_instal.log; fi }
system_cycle=1

log_txt='#! LOG_фаил'
while [ $system_cycle != 0 ] ;do
    clear
    echo -n "Хотите в конце установки ядра вывести LOG фаил  y/n (д/н) : "
    read questioner
    if [ "$questioner" != "${questioner#[YyДд]}" ] ;then
        test_log=0
        if [ $test_log == 0 ]; then echo "$log_txt = $questioner" >arch_instal.log; fi 
        system_cycle=0
    elif [ "$questioner" != "${questioner#[NnНн]}" ] ;then
        test_log=1
        system_cycle=0
    else
        test_log=1
    fi
done
system_cycle=1


log_txt='#! Установка'
while [ $system_cycle != 0 ] ;do
    clear
    echo -n "Начать установку  y/n (д/н) : "
    read questioner
    if [ "$questioner" != "${questioner#[YyДд]}" ] ;then
        log_questioner
        log_txt='#? Обновление_ключей'
        #!Обновление ключей для старых образов ArchLinux!!!
        while [ $system_cycle != 0 ] ;do
            clear
            echo -n "Обновим ключи  y/n (д/н) : "
            read questioner
            if [ "$questioner" != "${questioner#[YyДд]}" ] ;then
                log_questioner
                pacman-key --refresh-keys
                program_status=$?
                log_program
                system_cycle=0
            elif [ "$questioner" != "${questioner#[NnНн]}" ] ;then
                log_questioner
                system_cycle=0
            else
                log_questioner
                system_cycle=1
            fi
        done
        system_cycle=1
        log_txt='#? Разметка_диска'
        while [ $system_cycle != 0 ] ;do
            clear
            echo -n "Хотите разметить диск?  y/n (д/н) : "
            read questioner
            if [ "$questioner" != "${questioner#[YyДд]}" ] ;then
                log_questioner
                lsblk
                log_txt='#* Диск'
                echo -n "Укажите диск для разметки (sda) : "
                read questioner
                log_questioner
                log_txt='# cfdisk'
                sudo cfdisk /dev/$questioner
                program_status=$?
                log_program
                log_txt='#* Переразметка_диска'
                while [ $system_cycle != 0 ] ;do
                    clear
                    echo -n "Хотите переразметить диск?  y/n (д/н) : "
                    read questioner
                    if [ "$questioner" != "${questioner#[YyДд]}" ] ;then
                        log_questioner
                        lsblk
                        log_txt='#* Диск'
                        echo -n "Укажите диск для разметки (sda) : "
                        read questioner
                        log_questioner
                        log_txt='# cfdisk'
                        sudo cfdisk /dev/$questioner
                        program_status=$?
                        log_program
                        system_cycle=0
                    elif [ "$questioner" != "${questioner#[NnНн]}" ] ;then
                        log_questioner
                        system_cycle=0
                    else
                        log_questioner
                        system_cycle=1
                    fi
                done
            elif [ "$questioner" != "${questioner#[NnНн]}" ] ;then
                log_questioner
                system_cycle=0
            else
                log_questioner
                system_cycle=1
            fi
        done
        log_txt='#? Форматирование_дисков'
        while [ $system_cycle != 0 ] ;do
            clear
            echo -n "Форматировать диск?  y/n (д/н) : "
            read questioner
            if [ "$questioner" != "${questioner#[YyДд]}" ] ;then
                log_questioner
                log_txt='#* Core'
                while [ $system_cycle != 0 ] ;do
                    clear
                    echo -n "1 - Btrfs
                    2 - Ext4
                    0 - Корневой раздел не нужен
                    В какую файловую систекму будем форматировать корневой раздел раздел?   (0/1/2) : "
                    read questioner
                    if [ $questioner == 1 ] ;then
                        log_questioner
                        lsblk
                        log_txt='#* Btrfs_file_system'
                        echo -n "Укажите раздел для Core  (sda1) : "
                        read questioner
                        log_questioner
                        log_txt='# Форматирование в Btrfs'
                        mkfs.btrfs -f /dev/@questioner -L archlinux
                        program_status=$?
                        log_program
                        log_txt='# Монтируем корневой раздел'
                        mount /dev/@questioner /mnt
                        program_status=$?
                        log_program
                        system_cycle=0
                    elif [ $questioner == 2 ] ;then
                        log_questioner
                        lsblk
                        log_txt='#* Ext4_file_system'
                        echo -n "Укажите раздел для Core  (sda1) : "
                        read questioner
                        log_questioner
                        log_txt='# Форматирование в Ext4'
                        mkfs.ext4 -F /dev/$questioner -L archlinux
                        program_status=$?
                        log_program
                        log_txt='# Монтируем корневой раздел'
                        mount /dev/@questioner /mnt
                        program_status=$?
                        log_program
                        system_cycle=0
                    elif [ $questioner == 0 ]; then
                        log_questioner
                        system_cycle=0
                    else
                        log_questioner
                        system_cycle=1
                    fi
                done
                system_cycle=1
                log_txt='#* Efi_или_boot'
                while [ $system_cycle != 0 ] ;do
                    clear
                    echo -n "3 - Efi
                    4 - boot
                    0 - boot раздел не нужен
                    Какой загрузчик будем ставить?  (0/3/4) : "
                    read questioner
                    if [ $questioner == 3 ] ;then
                        log_questioner
                        lsblk
                        log_txt='#* Efi_system_boot'
                        echo -n "Укажите раздел для EFI  (sda1) : "
                        read questioner
                        log_questioner
                        log_txt='# Форматирование в vfat'
                        mkfs.vfat /dev/@questioner -L boot
                        program_status=$?
                        log_program
                        log_txt='# Создаём дерикторию boot'
                        mkdir /mnt/boot
                        program_status=$?
                        log_program
                        log_txt='# Создаём дерикторию EFI'
                        mkdir /mnt/boot/EFI
                        program_status=$?
                        log_program
                        log_txt='# Монттируем boot раздел'
                        mount /dev/@questioner /mnt/boot/EFI
                        program_status=$?
                        log_program
                        system_cycle=0
                    elif [ $questioner == 4 ] ;then
                        log_questioner
                        lsblk
                        log_txt='#* system_boot'
                        echo -n "Укажите раздел для BOOT  (sda1) : "
                        read questioner
                        log_questioner
                        log_txt='# Форматирование в Ext2'
                        mkfs.ext2 -F /dev/@questioner -L boot
                        program_status=$?
                        log_program
                        log_txt='# Создаём дерикторию Boot'
                        mkdir /mnt/boot
                        program_status=$?
                        log_program
                        log_txt='# Монттируем boot раздел'
                        mount /dev/@questioner mnt/boot
                        program_status=$?
                        log_program
                        system_cycle=0
                    elif [ $questioner == 0 ]; then
                        log_questioner
                        system_cycle=0
                    else
                        log_questioner
                        system_cycle=1
                    fi
                done
                system_cycle=1
                log_txt='#* swap'
                while [ $system_cycle != 0 ] ;do
                    clear
                    echo -n "5 - swap
                    0 - swap раздел не нужен
                    Форматируем swap раздел?  (0/5) : "
                    read questioner
                    if [ "$questioner" != "${questioner#[YyДд]}" ] ;then
                        log_questioner
                        lsblk
                        log_txt='#* Форматирование_swap'
                        echo -n "Укажите раздел для swap  (sda1) : "
                        read questioner
                        log_questioner
                        log_txt='# Форматирование swap'
                        swapon /dev/@questioner
                        program_status=$?
                        log_program
                        system_cycle=0
                    elif [ "$questioner" != "${questioner#[NnНн]}" ] ;then
                        log_questioner
                        system_cycle=0
                    else
                        log_questioner
                        system_cycle=1
                    fi
                done
                system_cycle=1
                log_txt='#* Home'
                while [ $system_cycle != 0 ] ;do
                    clear
                    echo -n "6 - Btrfs
                    7 - Ext4
                    0 - Домашний раздел не нужен
                    В какую файловую систекму будем форматировать home раздел?  (0/6/7) : "
                    read questioner
                    if [ $questioner == 6 ] ;then
                        log_questioner
                        lsblk
                        log_txt='#* Btrfs_file_system'
                        echo -n "Укажите раздел для Home  (sda1) : "
                        read questioner
                        log_questioner
                        log_txt='# Форматирование в Btrfs'
                        mkfs.btrfs -f /dev/@questioner -L home
                        program_status=$?
                        log_program
                        log_txt='# Монтируем домашний раздел'
                        mount /dev/@questioner /mnt/home
                        program_status=$?
                        log_program
                        system_cycle=0
                    elif [ $questioner == 7 ] ;then
                        log_questioner
                        lsblk
                        log_txt='#* Ext4_file_system'
                        echo -n "Укажите раздел для Home  (sda1) : "
                        read questioner
                        log_questioner
                        log_txt='# Форматирование в Ext4'
                        mkfs.ext4 -F /dev/@questioner -L home
                        program_status=$?
                        log_program
                        log_txt='# Монтируем домашкий раздел'
                        mount /dev/@questioner /mnt/home
                        program_status=$?
                        log_program
                        system_cycle=0
                    elif [ $questioner == 0 ]; then
                        log_questioner
                        system_cycle=0
                    else
                        log_questioner
                        system_cycle=1
                    fi
                done
                system_cycle=0
            elif [ "$questioner" != "${questioner#[NnНн]}" ] ;then
                log_questioner
                system_cycle=0
            else
                log_questioner
                system_cycle=1
            fi
        done
        system_cycle=1
        #!!!!!!!!!!Выбор зеркала мешает загрузке ядра!!!!!!!!!!!
        #!echo 'Выбор зеркал для загрузки.'
        #!rm -rf /etc/pacman.d/mirrorlist
        #!wget https://git.io/mirrorlist
        #!mv -f ~/mirrorlist /etc/pacman.d/mirrorlistr
        log_txt='#? Linux_kernel'
        while [ $system_cycle != 0 ] ;do
            clear
            echo -n "
            8 - ArchLinux kernel
            9 - Arch zen kernel
            Какое ядро устанавливаем?  (8/9) : "
            read questioner
            if [ $questioner == 8 ] ;then
                log_questioner
                log_txt='#* ArchLinux kernel'
                pacstrap -i /mnt base base-devel linux linux-headers linux-firmware dosfstools btrfs-progs intel-ucode iucode-tool nano dhcpcd netctl --noconfirm
                program_status=$?
                log_program
                log_txt='# Генерация конфига разделов'
                genfstab -U /mnt >> /mnt/etc/fstab
                program_status=$?
                log_program
                system_cycle=0
            elif [ $questioner == 9 ] ;then
                log_questioner
                log_txt='#* ArchLinux Zen kernel'
                pacstrap -i /mnt base base-devel linux-zen linux-zen-headers linux-firmware dosfstools btrfs-progs intel-ucode iucode-tool nano dhcpcd netctl --noconfirm
                program_status=$?
                log_program
                log_txt='# Генерация конфига разделов'
                genfstab -U /mnt >> /mnt/etc/fstab
                program_status=$?
                log_program
                system_cycle=0
            else
                log_questioner
                system_cycle=1
            fi
        done
        system_cycle=0




    elif [ "$questioner" != "${questioner#[NnНн]}" ] ;then
        log_questioner
        system_cycle=0
    else
        log_questioner
        system_cycle=1
    fi
done
system_cycle=1





arch-chroot /mnt

#arch-chroot /mnt sh -c "$(curl -fsSL git.io/archuefi2.sh)"
