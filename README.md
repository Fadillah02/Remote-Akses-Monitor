# Remote Akses Monitor

Streaming layar PC ke HP via WiFi.  
Gratis, open source, tanpa internet.

## Cara Pakai

### 1. Install
```
Klik kanan install.bat → Run as Administrator
```
Script otomatis download + install:
- **Sunshine** — server streaming
- **MttVDD** — virtual display driver

### 2. Pairing HP
```
1. Buka https://localhost:47990  (login admin/admin)
2. Install Moonlight di HP (Play Store)
3. Buka Moonlight → Add Host → IP PC
4. Masukkan PIN dari HP ke tab PIN Sunshine
5. Pilih "Desktop"
```

### 3. Virtual Display (opsional)
```
Win+P → Extend → pilih "VDD by MTT"
```
Agar game/aplikasi jalan di layar virtual, tidak mengganggu monitor utama.

### Start/Stop Manual
```cmd
net start SunshineService    // Start
net stop SunshineService     // Stop
```

## Keamanan
Script download file dari GitHub releases resmi:
- [nefcon](https://github.com/lordmulder/nefcon)
- [MttVDD](https://github.com/MountainTech/MTT-VDD)
- [Sunshine](https://github.com/LizardByte/Sunshine) (via winget)

Tidak ada binary yang di-bundle dalam repo ini.

## Lisensi
MIT — bebas pakai, edit, distribusi.
