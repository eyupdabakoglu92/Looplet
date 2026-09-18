# Prompt Execution Gating Standard

> Status: SHARED SUPPLEMENT / NON-AUTHORITATIVE
>
> Bu doküman delivery ve review prompt'larında tekrar eden execution gating kurallarını toplar. Normatif execution semantics authority yine `role-execution-contract.md` içindedir.

Last Updated: 2026-04-09

---

## Purpose

Bu dosya:

* role label integrity ve active task resolution tekrarını azaltmak
* prompt'lar arasında aynı gating dilini korumak
* role-specific prerequisites ile shared execution resolution kurallarını ayırmak

---

## Shared Execution Gating Rules

Bir rol çalışmaya başlamadan önce:

* exact canonical role label bekler
* aktif feature ve actionable task çözümlemesini `role-execution-contract.md` kurallarına göre yapar
* delivery için Done/Closed/Blocked olmayan tek feature üzerinde çalışır; Tech Lead kontrol işleri ve PO bootstrap/revision istisnadır
* ledger varsa boş/None olsa da yalnız onu kullanır
* ledger hiç yoksa exact role section'ından legacy fallback kullanılır; full handoff öncesi normalize edilir
* aynı role ait çoklu task belge/dependency sırasıyla çalışılır
* bekleyen product revision etkilenen feature'da resync'e kadar delivery'yi durdurur

Task resolution sırasında aşağıdaki alanlardan görev çıkarılmaz:

* `Change Log`
* `System History`
* code block checklist'leri
* struck-through cancelled item'lar
* archived / reference brief'ler

---

## Shared Escalation Rule

Gating güvenilir değilse rol kendi başına iş uydurmaz.

Örnek riskler:

* owner etiketi canonical değil
* task assignment net değil
* authoritative task ve role eşleşmiyor

Bu durumda role-specific prompt içinde tanımlı escalation davranışı uygulanır.

---

## Role-Specific Reminder

Bu standart, role-specific prerequisites'in yerini tutmaz.

Örnek:

* QA için implementasyonların tamamlanmış olması
* Project Setup için yeni scaffold veya aynı açık task/target içinde güvenli partial resume
* DevOps/Release Engineer için release/deployment task'ının açık olması
* UI Designer için actionable design task bulunması

Bu koşullar ilgili prompt içinde ayrıca kalmalıdır.
