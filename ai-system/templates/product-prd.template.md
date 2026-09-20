# 1. Product Overview

{Bu ürün nedir? Kime hizmet eder? Temel problem nedir?}

---

# 2. Business Goals

* {goal}
* {goal}

Beklenen çıktı:

* {expected outcome}

---

# 3. Target Users

## 3.1 Primary Users

* {user segment}

## 3.2 User Needs

* {need}
* {need}

---

# 4. Core Capabilities

* {capability}
* {capability}

---

# 5. High-Level User Flows

## 5.1 {Flow Name}

1. {step}
2. {step}
3. {step}

---

# 5.1 Experience & Brand Intent

* Desired user feeling: {feeling}
* Experience adjectives: {three adjectives}
* The product must never feel: {anti-goals}
* Category quality references named by the user: {references or "Not specified"}
* Signature moments where visual/motion/audio/haptic quality affects product value: {moments or "None identified"}
* Accessibility and reduced-motion expectations: {expectations}

---

# 6. Feature List

| ID | Feature Name | Description | Priority | Dependency | User Value | Success Metric |
| -- | ------------ | ----------- | -------- | ---------- | ---------- | -------------- |
| F01 | {feature-name} | {description} | P0 | None | {value} | {metric} |

---

# 6.1 Feature Details

## {feature-name}

### Tip

> User-Facing / Infrastructure

Kural:
* User-Facing: kullanıcıya doğrudan dokunan → User Stories yaz
* Infrastructure: altyapı ve sistem feature'ları → System Requirements yaz

### User Stories (User-Facing için)

* As a {user}, I want {behavior}, so that {value}.

### System Requirements (Infrastructure için)

* The system must {behavior} so that {value}.

### Acceptance Criteria

* Given {state}
* When {action}
* Then {outcome}

### Edge Cases

* {edge case}

### Notes

* {note}

---

# 7. MVP Scope

İlk versiyonda yapılacak feature'lar ve gerekçesi:

* {feature-id} — {why}

MVP dışında bırakılanlar:

* {feature-id} — {why later}

---

# 8. Non-Functional Expectations

* Performans: {beklenti}
* Güvenlik: {beklenti}
* Ölçeklenebilirlik: {beklenti}
* Kullanılabilirlik: {beklenti}
* Experience quality: {görsel, motion ve feedback kalite beklentisi}

---

# 9. Risks / Dependencies

* {risk veya dependency}

---

# 10. Assumptions

* {varsayım}

---

# 11. Open Questions

Kural:
* Karar verilmişse `→ Decision:` satırı ekle
* Sahibi belirsizse `→ Owner: Tech Lead` yaz

* {soru}
  → Owner: Tech Lead

---

# 12. Tech Preferences & Constraints

Kural:
* Bu bölüm teknik stack kararı içermez
* Kullanıcının belirttiği kısıt ve tercihleri yakalar
* Tech Lead bu bölümü `platform.md` üretmek için kullanır

* Platform: {iOS / Android / Web / cross-platform / CLI / belirtilmedi}
* Dil / Framework tercihi: {tercih veya "Tech Lead belirleyecek"}
* Entegrasyonlar: {3. taraf API, legacy sistem veya "Yok"}
* Deployment / Hosting / CI-CD tercihi: {tercih veya "Tech Lead belirleyecek"}
* Ölçek / Performans kısıtı: {kısıt veya "Tech Lead belirleyecek"}
* Güvenlik kısıtı: {kısıt veya "Tech Lead belirleyecek"}

---

# 13. Delivery Note for Tech Lead

* {Sistemin hızlı anlaşılması için özet}
* Kritik karar gerektiren alanlar: {alan}
* System-level riskler: {risk}
* Platform kararı Tech Lead'e bırakılmıştır; `platform.md` bu PRD ve Section 12 temelinde üretilir

---

# 14. Success Metrics

Her kritik feature için ölçülebilir hedefler:

* {feature-id}: {metric}

---

# 15. Domain Model (PO-Level)

Kural:
* Teknik implementasyon değil, iş nesnelerini tanımlar
* Tech Lead bu modeli mimari kararları için kullanır

## Core Entities

### {Entity Name}

* {field}: {description}

---

# 16. Core Domain Events

Kural:
* Kritik state geçişlerini tetikleyen olayları listele
* Event isimleri UPPER_SNAKE_CASE olmalı

* {EVENT_NAME} — {kısa açıklama}
