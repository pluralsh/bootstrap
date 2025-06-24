data "aws_route53_zone" "prod" {
  name = "{{ .AppDomain }}"
}

resource "aws_route53_zone" "dev" {
  name = "dev.{{ .AppDomain }}"
}

resource "aws_route53_record" "dev-ns" {
  zone_id = data.aws_route53_zone.prod.zone_id
  name    = "dev.{{ .AppDomain }}"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.dev.name_servers
} 