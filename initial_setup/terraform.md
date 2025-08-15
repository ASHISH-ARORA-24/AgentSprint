# Terraform Installation Steps (Ubuntu)

## 1. Remove any old Terraform binary
```bash
sudo rm /usr/local/bin/terraform
```

## 2. Download the latest stable release (update version as needed)
```bash
wget https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip
```

## 3. Unzip the binary
```bash
unzip terraform_1.12.2_linux_amd64.zip
```

## 4. Move the binary to /usr/local/bin
```bash
sudo mv terraform /usr/local/bin/
```

## 5. Verify installation
```bash
terraform -version
```

## 6. Troubleshooting
If you see an error about the binary location, start a new terminal or run:
```bash
hash -r
terraform -version
```

---

Refer to this file for step-by-step Terraform setup instructions.
