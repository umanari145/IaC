# Infrastructure as Code

## terraform

参考リンク<br>
https://qiita.com/bunty/items/5ceed66d334db0ff99e8<br>
https://blog.dcs.co.jp/aws/20210401-terraformaws.html

### ファイル構成

.teffaorm.lock.hcl・・キャッシュファイル<br>
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

- APIgateway

  - APIgateway のサンプル
    - \*\*\_rest_api API 本体
    - \*\*\_resource
    - https://dev.classmethod.jp/articles/terraform-deployment-rest-api-gateway
    - https://colabmix.co.jp/tech-blog/terraform-api-gateway/

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

- azure(やや頓挫気味)

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

- cloudformation
  - main.yaml gw-rm-psn\*1 (gateway-routetable-PublicSubnet1)
  - inc_parivate_subnet.yaml(gatewa-routetab-le-PublicSubnet1-PrivateSubnet2 PrivateSubnet3 3 は孤立状態)

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

ECS

- VPC
- Internet Gateway
- Route table
- ALB
- ECS
- Cloud Watch

VPC_NAT

- VPC
- Internet Gateway
- Route table
- NAT
- Subnet

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

## 変数

### locals の定義と variable

- locals・・ローカル変数で外部から変更負荷
- variables・・外部から変更可能(コマンドライン実行時やファイル指定)

local

```
locals {
  project = "hogehoge"
}

resource <RESOURCE_TYPE> <RESOURCE_NAME> {
  tags = "${local.project}-vpc"
}

```

variable

```
variable "project" {
  type = string
  default = "hogehoge"
}

resource <RESOURCE_TYPE> <RESOURCE_NAME> {
  tags = "${var.project}-vpc"
}
```

変数の方としてはプリミティブ以外にオブジェクト型なども

```
variable "message" {
  type = string
  default = "test"
}

# オブジェクト
variable "obj_sample" {
  type = object({
    name = string
    age = number
  })
  default = {
    name = "tanaka"
    age = 28
  }
}

参照時は
var.obj_sample.name

#リスト
variable "list_sample" {
  type = list(string)
  default = ["tanaka", "sato]
}

var.list_sample[0]

#map
variable "map_sample" {
  type = map(string)
  default = {
    "High" = "x2.large"
    "Low" = "x2.nano"
  }
}
var.map_sample.High
```

### 変数の上書き

variables で定義してることを前提に・・・

環境変数(TF*VAR*が接頭語)

```
export TF_VAR_message
```

変数ファイル

\*\*\*.vfvars

```
message = "sample message"

```

-var での上書き

```
terraform apply - var message="sample message"
```

変数の優先度はコマンド引数>変数ファイル>環境変数

### data

すでに定義されている値を定数的に定義する

```
data"aws_iam_user""my_user"{
  user_name="my_user_name"
}
```

## ECS に関して

- オートスケーリングの設定の必要あり
- スケーリングポリシー

### 負荷テスト

apache ベンチや JMeter など動的に負荷をかけられるサービスを使う

総合試験でのテスト内容など(
https://skill-up-engineering.com/2022/01/29/%e7%b7%8f%e5%90%88%e8%a9%a6%e9%a8%93%e3%81%a7%e3%81%ae%e3%83%86%e3%82%b9%e3%83%88%e5%86%85%e5%ae%b9%e3%81%aa%e3%81%a9/)

## drawIO おすすめプラグイン

drawIO Integration

## awspec

インフラのテストツール
<br>2024/07 現在の ruby bundler の version

```
root@7d4fac1b71bf:/home/app# ruby -v
ruby 3.3.3 (2024-06-12 revision f1c7b6f435) [x86_64-linux]
root@7d4fac1b71bf:/home/app# bundler -v
Bundler version 2.5.11
```

## cloudformation

cli コマンド<br>
https://dev.classmethod.jp/articles/read-aws-cli-cfn-options/

スタック・・単一のリソースではなく、リソースをグループ化したもの

確認

```
aws cloudformation validate-template \
 --template-body file://main.yaml

# レスポンス
{
    "Parameters": []
}
```

作成

```
aws cloudformation create-stack \
  --template-body file://main.yaml \
  --stack-name mynetwork
# レスポンス
{
    "StackId": "arn:aws:cloudformation:us-west-1:xxxxx:stack/mypvc/zzzzzzzzz"
}
```

変更時は一気に更新するよりは変更セットを作ってみた方が差分が確認しやすい。

変更セットを作成

```
aws cloudformation create-change-set \
 --stack-name  mynetwork3 \
 --template-body file://vpc.yaml  \
 --change-set-name addSubnet

# レスポンス
{
    "Id": "arn:aws:cloudformation:us-west-1:xxxx:changeSet/addSubnet/yyyy",
    "StackId": "arn:aws:cloudformation:us-west-1:xxxx:stack/mynetwork3/yyyy"
}
```

変更セットの確認(差分が確認できる)

```
aws cloudformation describe-change-set \
  --change-set-name addSubnet \
  --stack-name mynetwork3

# レスポンス
{
    "Changes": [
        {
            "Type": "Resource",
            "ResourceChange": {
                "Action": "Add",
                "LogicalResourceId": "RouteTable02a",
                "ResourceType": "AWS::EC2::RouteTable",
                "Scope": [],
                "Details": []
            }
        },
        {
・・・・・・・・

```

変更セットの確定

```
aws cloudformation execute-change-set \
 --change-set-name addSubnet \
 --stack-name mynetwork3

# レスポンスは特にない
```

一気に更新

```
aws cloudformation update-stack \
  --template-body file://main.yaml \
  --stack-name mynetwork

```

デプロイ

```
aws cloudformation deploy \
  --template-file main.yaml \
  --stack-name mynetwork

Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - mypvc
```

スタックの削除

```
aws cloudformation delete-stack --stack-name mynetwork

```

スタックの一覧

```
aws cloudformation describe-stacks
```

### modules

パーツをこの部分で実装

- sns_topic

### テンプレート内部の変数について

Ref 組み込み関数 Ref は、指定したパラメータまたはリソースの値

例)
!Ref 論理名
パラメータの論理名を指定すると、それはパラメータの値<br>
リソースの論理名を指定すると、それはそのリソースを参照するために通常使用できる値

### ネットワークについて

プレイベート IP<br>
10.0.0.0 - 10.255.255.255 (10/8 プレフィックス)<br>
172.16.0.0 - 172.31.255.255 (172.16/12 プレフィックス)<br>
192.168.0.0 - 192.168.255.255 (192.168/16 プレフィックス)

CIDR ブロックに関して<br>
なるべく大きくとった方が多くの AWS リソースを格納できる

インターネットゲートウェイと NAT ゲートウェイ<br>
インターネットゲートウェイ・・VPC が外部と接続するために必要なコンポーネント<br>
NAT ゲートウェイ・・プライベートサブネットから VPC 外に接続するために使用されるコンポーネント。<br>
https://qiita.com/KWS_0901/items/8f818caaa4e989a185c5<br>
https://milestone-of-se.nesuke.com/sv-advanced/aws/internet-nat-gateway/

サブネットに関して
https://www.stylez.co.jp/aws_columns/understand_the_basics_of_aws_networking/understanding_aws_public_subnets_and_private_subnets/

### ポリシーについて

基本的には付与したい複数の許可(ポリシー)をロールに集め、それをリソース(例 Stepfunction)に付与する感じ。<br>

- AWS 管理ポリシー(ManagedPolicy)　・・AWS に元々付与されているポリシー(AmazonEC2FullAccess 等。)
- カスタマー管理ポリシー・・ ユーザーが独自に作成するポシリーのこと
- インラインポリシー・・ユーザー、グループ、ロールに埋め込まれたポリシー(他の IAM に付与できず特定の IAM 専属という感じ。インライン CSS とイメージが近いかも)

ポシリー

```
  MyCustomPolicy:
    Type: 'AWS::IAM::Policy'
    Properties:
      PolicyName: MyCustomPolicy
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow (Allow or Deny)
            Action:
              - 's3:ListBucket' (AWSサービス名:操作)
              - 's3:GetObject'
            Resource:
              - 'arn:aws:s3:::example-bucket'　(適用される範囲)
              - 'arn:aws:s3:::example-bucket/*'
      Roles:
        - Ref: MyExampleRole
```

### ロールについて

ロール

```
  CodeDeployServiceRole:
    Type: "AWS::IAM::Role"
    Properties:
      RoleName: "CodeDeployServiceRole"
      # CodeDeployが他のサービスにアクセスする
      Description: "Allow CodeDeploy to call AWS all service"
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: "Allow"
            Principal:
              Service:
                - "codedeploy.amazonaws.com" (CodeDeployサービスがこのロールを引き受けることを許可します。)
            Action:
              - "sts:AssumeRole" (このロールを引き受けるアクションを許可します。)
      ManagedPolicyArns:
        - "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole" (このロールにアタッチされる管理ポリシーのARN)

```

### サービスロール

ユーザーに無制限に操作権限を与えるとまずいので、AWS のあるサービスに対して、別のサービスへの操作権限を許可
https://qiita.com/sakuraya/items/920b9d0b549c8c412416<br>

### CodeDeploy

- cloudformation
  - coude_deploy(EC 作成時には main.yaml で VPC をつくる)
    - appspec.yaml
    - CodeDeploy.yaml
    - EC2
    - IAM.yaml
    - S3.yaml

CodeDeploy<br>
https://qiita.com/tsukapah/items/598ef327ccc51b4955b6<br>
https://qiita.com/terukizm/items/e2c1400d129042868731<br>
https://jitera.com/ja/insights/9418
<br>
EC2<br>
https://qiita.com/tyoshitake/items/c5176c0ef4de8d7cf5d8<br>

```
aws cloudformation create-stack \
  --template-body file://IAM.yaml \
  --stack-name code_deploy_IAM \
  --capabilities CAPABILITY_NAMED_IAM

 aws cloudformation create-stack \
  --template-body file://S3.yaml \
  --stack-name codeDeployS3
```

```

```

appspec とは・・・デプロイプロセスを定義するための設定ファイル<br>

BeforeInstall: アプリケーションの新しいバージョンをインスタンスにコピーする前に実行されるスクリプト。<br>
AfterInstall: アプリケーションの新しいバージョンがインスタンスにコピーされた後に実行されるスクリプト。<br>
ApplicationStart: アプリケーションが開始された後に実行されるスクリプト。<br>
ValidateService: デプロイが正常に完了したことを検証するために実行されるスクリプト。

## 参考教材

「AWS CloudFormation を使って VPC 環境を構築してみよう！」(https://www.techpit.jp/courses/77)<br>
「AWS と Terraform で実現する Infrastructure as Code」(https://www.udemy.com/course/iac-with-terraform/)<br>
「AWS で Docker を本番運用！AmazonECS を使って低コストでコンテナを運用する実践コース」(https://www.udemy.com/course/ecsfargate/)
