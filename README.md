# S3-Lambda 데이터 파이프라인 구축 실습 (Terraform)

Terraform을 사용해서 AWS S3와 Lambda를 연동하는 서버리스 데이터 파이프라인을 구축하는 실습입니다. S3 버킷에 CSV 파일이 업로드되면 Lambda 함수가 자동으로 트리거되어 데이터의 헤더를 검증하고 정제된 버킷으로 이동시킵니다.

## 전체 구조
1. **S3 Raw Bucket**: 사용자가 CSV 파일을 업로드하는 공간입니다.
2. **Lambda**: S3 이벤트를 감지하여 실행되며, 파이썬 코드로 데이터를 검증합니다.
3. **S3 Clean Bucket**: 검증이 완료된 파일이 저장되는 최종 목적지

## 사전 준비 사항
* **AWS CLI**: 설치 및 `aws configure`를 통한 계정 설정(Access Key, Secret Key 필요)
* **Terraform**: 설치 및 환경 변수 등록

## 파일 구조
* `main.tf`: AWS Provider 및 S3 버킷, IAM 권한 정의
* `lambda.tf`: Lambda 함수 정의 및 S3 Trigger 설정
* `variables.tf`: 버킷 이름 등 재사용되는 변수 관리
* `src/lambda_function.py`: 데이터 검증 로직이 담긴 파이썬 소스 코드

## 📝 사용 방법


1. 필요한 Provider 플러그인을 다운로드합니다.
```bash
terraform init
```
   
2. 생성될 8개의 리소스를 미리 검토합니다.
```bash
terraform plan
```
   
3. 실제 AWS상에 리소스를 생성합니다.
```bash
terraform apply -auto-approve
```

4. test.csv 파일을 생성하여 raw 버킷에 업로드하고 파이프라인 작동을 확인합니다.
```bash
aws s3 cp test.csv s3://<본인의-raw-버킷-이름>/
aws s3 ls s3://<본인의-clean-버킷-이름>/
```
   
5. 실습 종료 후 과금을 방지하기 위해 반드시 모든 자원을 삭제해야 합니다!
```bash
terraform destroy -auto-approve
```
