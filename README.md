# Infrastructure as Code

## terraform

参考リンク<br>
https://qiita.com/bunty/items/5ceed66d334db0ff99e8<br>
https://blog.dcs.co.jp/aws/20210401-terraformaws.html

### ファイル構成

.teffaorm.lock.hcl・・キャッシュファイル
.terraform.tfstate・・現状の状況を記載(composer.lock に近い)

### インストール

terraform 本体のインストール

```
brew install terraform
terraform --version
#Terraform v0.12.26でOK
```

tfenv(terraform のバージョン切り替え)

```
#個別に元々インストールしていた場合は以下のコマンドでアンインストール
brew unlink terraform

brew install tfenv
tfenv --version
# tfenv 2.2.2


#想定のバージョンをインストール
tfenv list-remote
# バージョンがずらずらと・・
#その中で選んでインストール
tfenv install 1.0.0
# インストールずみのバージョンを表記
tfenv list
#  1.0.0
# No default set. Set with 'tfenv use <version>' //まだ設定されていない
# 実際に仕様
tfenv use 1.0.0

# 使用後確認するとシンボリックリンクを貼る
tfenv list
* 1.0.0 (set by /usr/local/Cellar/tfenv/2.2.2/version)
```

### atom プラグイン

- language-terraform:シンタックスハイライト(色つけ)
- linter-terraform-syntax:構文チェック
- terraform-fmt:整形ツール

### vscode

- Draw.io Integration: draw をエディタ上に表現

下記のコマンドは全て terraform ディレクトリにおりて実行する

### ファイル構成(各プロバイダーごと)

共通系

- chart 構成を drawio で保存
- .terraform.lock.hcl ライブラリの状態保存
- terraform.tfstate.\* 状態のファイル(AWS の状態がここに保存される)
- provider.tf aws アカウントの情報
- variables.tf(変数の格納)

- aws_ec2

  - vpc ネットワーク関連(ゲートウェイ、ルートテーブル、サブネットマスク、セキュリティグループなど)
  - ec2 ec2-Instance コマンドについて
  - keygen 鍵の生成(秘密鍵と公開鍵キーペアの作成)
  - elb ロードバランサーの設定

- aws_ecs
  - ecr ecr の作成
    - ecr.tf リポジトリ
    - app nginx の Docker
    - nginx web の Docker
    - src 実際にデプロイされるファイル
    - aws_ecr_lifecycle_policy ライフサイクルの json
    - ecr_push.sh ECR のプッシュのシェル
    - provider.tf (../provider.tf のシンボリックリンク)
  - ecs ecs の作成
    - ecs.tf クラスター、サービス、タスクの登録
    - iam.tf ecs に必要な IAM
    - vpc.tf ネットワーク関連
    - lb アプリケーションロードバランサー

https://hi1280.hatenablog.com/entry/2023/04/07/200303

https://qiita.com/Shoma0210/items/b998a260c5d18839fb7a

- azure

  - main.tf (リソースグループ、Vnet、サブネット、パブリック IP、アプリケーションゲートウェイまで。ただし http_listener に関しては何度も作り直しが発行されてしまう。)
  - acr_aks.tf(別サービスが自動的に作られうまく紐づかない・・・のと失敗したのに aks が作例されてしまっている)

azure に関しては provider でアカウント情報をコントロールするのではなく、az login 後おこなう(以下のようなページがでます)

```
[
  {
    "cloudName": "AzureCloud",
    "managedByTenants": [],
    "name": "Azure サブスクリプション 1",
    "state": "Enabled",
    "user": {
    }
  },
  {

  }
]
```

- ディレクトリ自体がプロジェクトのようなもの
  aws 用に./aws を作った場合にはここで terraform (init|plan|apply|show)コマンドをとる

#### 1 terraform init

ディレクトリごとに行うため git に近い

ec2.tf ファイルと variables.tf を作成し、一番最初に打つコマンド(何もないと動かない)<br>
aws のアカウント情報などの初期化をしている(composer install などに近いイメージ)<br>
下記のようなメッセージが出れば OK<br>
また.terraform にライブラリがインストールされる

```

Initializing the backend...

Initializing provider plugins...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 2.65"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

variable.tf などが同階層にあると下記のようなエラーがでる<br>
aws アカウントの重複

```
Error: Duplicate provider configuration
```

#### 2 terraform plan

オプション `-var-file ***.tfvars`で変数を取り込むことができる

構文チェックと新規に追加された要素の確認(確認事項)

```
provider.aws.region
  The region where AWS operations will take place. Examples
  are us-east-1, us-west-2, etc.

  Enter a value: us-east-1

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.web1 will be created
  + resource "aws_instance" "web1" {
      + ami                          = "ami-0323c3dd2da7fb37d"
      + arn                          = (known after apply)
      + associate_public_ip_address  = (known after apply)
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t2.micro"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = (known after apply)
      + network_interface_id         = (known after apply)
      + outpost_arn                  = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + security_groups              = (known after apply)
      + source_dest_check            = true
      + subnet_id                    = (known after apply)
      + tags                         = {
          + "Name" = "web1"
        }
      + tenancy                      = (known after apply)
      + volume_tags                  = (known after apply)
      + vpc_security_group_ids       = (known after apply)

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

```

もしすでに適用されているとすると以下のようなメッセージが出る(基本的には terraform.tfstate との差分を見ている)

```
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

```

ちなみにエラーの場合は以下のようなメッセージが出る

```
╷
│ Error: Reference to undeclared resource
│
│   on vpc.tf line 28, in resource "aws_route_table" "sample_rtb":
│   28:     gateway_id = aws_internet_gateway.sample_igw.id
│
│ A managed resource "aws_internet_gateway" "sample_igw" has not been declared in the root module.
```

#### 3 (sudo) terraform apply

plan 同様オプション `-var-file ***.tfvars`で変数を取り込むことができる

権限変更などで sudo が必要なケースがある

実際の実行。
AWS の管理画面を見るとインスタンスが実際に立ち上がっている

```
provider.aws.region
  The region where AWS operations will take place. Examples
  are us-east-1, us-west-2, etc.

  Enter a value: us-east-1


An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.web1 will be created
  + resource "aws_instance" "web1" {
      + ami                          = "ami-0323c3dd2da7fb37d"
      + arn                          = (known after apply)
      + associate_public_ip_address  = (known after apply)
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t2.micro"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = (known after apply)
      + network_interface_id         = (known after apply)
      + outpost_arn                  = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + security_groups              = (known after apply)
      + source_dest_check            = true
      + subnet_id                    = (known after apply)
      + tags                         = {
          + "Name" = "web1"
        }
      + tenancy                      = (known after apply)
      + volume_tags                  = (known after apply)
      + vpc_security_group_ids       = (known after apply)

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.web1: Creating...
aws_instance.web1: Still creating... [10s elapsed]
aws_instance.web1: Still creating... [20s elapsed]
aws_instance.web1: Still creating... [30s elapsed]
aws_instance.web1: Creation complete after 31s [id=i-0a2edbaf3f18d8eb0]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

この時点で terraform.tfstate が作られる(状態を管理?)

ファイルを更新して、apply をすると差分ができるので実行される

#### 4 terraform show

実際のリソースの状態を出力する(terraform.tfstate の中身をわかりやすく出力している)<br>
以下のようにリソースを指定することができる

```
terraform show aws_ecr_repository.ecr-nginx:
```

```
# aws_instance.web1:
resource "aws_instance" "web1" {
    実際のインスタンスの実データ
```

#### 5 terraform destory

既存のコードの消去<br>
建てたものも完全に消去される

```
provider.aws.region
  The region where AWS operations will take place. Examples
  are us-east-1, us-west-2, etc.

  Enter a value: us-east-1

aws_instance.web1: Refreshing state... [id=i-0a2edbaf3f18d8eb0]

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
matsumotogaseinoMacBook-ea:terraform matsumoto$ terraform destroy
provider.aws.region
  The region where AWS operations will take place. Examples
  are us-east-1, us-west-2, etc.

  Enter a value: us-east-1

aws_instance.web1: Refreshing state... [id=i-0a2edbaf3f18d8eb0]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.web1 will be destroyed
  - resource "aws_instance" "web1" {
        実際のインスタンスの実データ
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_instance.web1: Destroying... [id=i-0a2edbaf3f18d8eb0]
aws_instance.web1: Still destroying... [id=i-0a2edbaf3f18d8eb0, 10s elapsed]
aws_instance.web1: Still destroying... [id=i-0a2edbaf3f18d8eb0, 20s elapsed]
aws_instance.web1: Still destroying... [id=i-0a2edbaf3f18d8eb0, 30s elapsed]
aws_instance.web1: Destruction complete after 34s

Destroy complete! Resources: 1 destroyed.
```

### tips

特定の resource を指定したいとき

```
terraform (plan or apply or delete) --target={リソース名}.{リソースにつけた独自の名前}
# 例　terraform apply --target=aws_vpc.main


```

複数の profile を使い分けたいとき(下記をセットしておく)

```
export AWS_PROFILE=<profile名>
```

Local Values とはモジュール内に閉じて使える変数。モジュール内でのローカル変数のようなもの。

```
# 許可IPなど(一般的には自分のIP)
locals {
  admit_ip  = "113.149.17.185"
  azs = ["us-east-1a","us-east-1b"]
  cidr_block = [
    "10.0.1.0/24", "10.0.2.0/24"
  ]
}

resource "aws_security_group" "elb-sg" {
  ・・・・・
  ingress {
 　　・・・・
    cidr_blocks = ["${local.admit_ip}/32"]
  }
```

#### terraform state list リソース一覧

```
terraform state list
# tfstateで記載されている一覧を表示　以下例
# aws_ecr_repository.ecr-nginx
```

### 一般的なインフラネタ

ロードバランサーについて<br>
https://www.isoroot.jp/blog/4584/<br>
https://github.com/knakayama/tf-alb-demo<br>

### chart

インフラ関連の図の資料
https://www.draw.io/

VPC_diagram

- VPC
- Internet Gateway
- Route table
- EC2

EC2_DB_diagram

- VPC
- Internet Gateway
- Route table
- EC2
- RDS(MySQL)

EC2_sample

- VPC
- Internet Gateway
- Route table
- ALB
- EC2 × 2

## terraform validate

設定情報がおかしくないかの確認

```
╷
│ Warning: Argument is deprecated
│
│ with aws_ecs_cluster.sample_ecs_cluster,
│ on ecs.tf line 7, in resource "aws_ecs_cluster" "sample_ecs_cluster":
│ 7: capacity_providers = [
│ 8: "FARGATE",
│ 9: "FARGATE_SPOT"
│ 10: ]
│
│ Use the aws_ecs_cluster_capacity_providers resource instead
╵
╷
│ Error: Reference to undeclared resource
│
│ on iam.tf line 38, in resource "aws_iam_role_policy_attachment" "ecs_task_execution":
│ 38: role = aws_iam_role.ecs_task_execution_sample.name
│
│ A managed resource "aws_iam_role" "ecs_task_execution_sample" has not been declared in the root module.
```

## drawIO おすすめプラグイン

drawIO Integration
