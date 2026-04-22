# Server Room — Azure Cloud Infrastructure

Infrastruktura chmurowa dla środowiska serwerowego wdrożona na Microsoft Azure przy użyciu Terraform. Projekt symuluje przeniesienie serwerowni do chmury z podziałem na warstwy: sieciową, obliczeniową, monitoringu i kopii zapasowych.

## Architektura

```
Internet
    │
    ▼
[Load Balancer] ── publiczne IP
    │
    ▼
[App Subnet 10.0.1.0/24]
  ├── app-vm-0  (Ubuntu 22.04, Standard_B1s)
  └── app-vm-1  (Ubuntu 22.04, Standard_B1s)
    │
    ▼ (port SQL)
[DB Subnet 10.0.2.0/24]
  └── db-vm     (Ubuntu 22.04, Standard_B1s)
```

Wszystkie maszyny podłączone do **Log Analytics Workspace** (monitoring) i **Recovery Services Vault** (backup dzienny o 23:00 UTC, retencja 7 dni).

## Moduły Terraform

| Moduł | Opis |
|---|---|
| `modules/networking` | VNet, subnety, NSG, publiczne IP, Load Balancer |
| `modules/compute` | 2× App VM + 1× DB VM, Availability Set |
| `modules/monitoring` | Log Analytics Workspace, rozszerzenie OMS Agent |
| `modules/backup` | Recovery Services Vault, polityka backup VM |

## Środowiska

- `environments/dev` — środowisko deweloperskie (aktywne CI/CD)
- `environments/prod` — środowisko produkcyjne

## Wymagania

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) lub konto serwisowe z uprawnieniami Contributor
- Subskrypcja Azure z aktywnym Resource Group `terraform-state-rg` i Storage Account do backendu

## Pierwsze uruchomienie

```bash
# Zaloguj się do Azure
az login

# Przejdź do wybranego środowiska
cd environments/dev

# Zainicjuj backend i pobierz providery
terraform init

# Podejrzyj plan zmian
terraform plan \
  -var="admin_username=azureuser" \
  -var="ssh_public_key=$(cat ~/.ssh/id_ed25519.pub)" \
  -var="home_ip=$(curl -s ifconfig.me)/32"

# Wdróż infrastrukturę
terraform apply
```

## Zmienne

| Zmienna | Opis | Domyślna |
|---|---|---|
| `environment` | Nazwa środowiska (`dev` / `prod`) | `dev` |
| `location` | Region Azure | `swedencentral` |
| `admin_username` | Użytkownik SSH na VM | — |
| `ssh_public_key` | Klucz publiczny SSH | — |
| `home_ip` | Twoje publiczne IP w notacji CIDR (np. `1.2.3.4/32`) | — |
| `app_vm_size` | Rozmiar VM aplikacyjnych | `Standard_B2s_v2` |
| `db_vm_size` | Rozmiar VM bazodanowej | `Standard_B2s_v2` |

Zmienne wrażliwe (`admin_username`, `ssh_public_key`, `home_ip`) nie powinny być commitowane — przekazuj je przez `-var` lub plik `.tfvars` dodany do `.gitignore`.

## CI/CD (GitHub Actions)

Pipeline `.github/workflows/terraform-cicd.yml` działa na zmiany w `environments/dev/**`:

- **Pull Request** → `terraform plan` + komentarz z planem na PR
- **Push do `master`** → `terraform apply`

Wymagane sekrety w repozytorium:

| Sekret | Opis |
|---|---|
| `AZURE_CREDENTIALS` | JSON z danymi service principal (`az ad sp create-for-rbac`) |
| `SSH_PUBLIC_KEY` | Klucz publiczny SSH do VM |

## Bezpieczeństwo sieci (NSG)

**App Subnet:**
- HTTP (80) i HTTPS (443) otwarte z internetu
- SSH (22) tylko z `home_ip` oraz management subnet
- Outbound SQL tylko do DB Subnet

**DB Subnet:**
- SQL tylko z App Subnet
- SSH tylko z management subnet

## Outputs

Po `terraform apply` dostępne są:

```
load_balancer_public_ip  — publiczny IP do aplikacji
app_vms_private_ips      — prywatne IP maszyn aplikacyjnych
```

## Backend stanu

Stan Terraform przechowywany zdalnie w Azure Blob Storage:

```
Storage Account : tfstate1232137
Container       : tfstate
Key (dev)       : dev/terraform.tfstate
```
