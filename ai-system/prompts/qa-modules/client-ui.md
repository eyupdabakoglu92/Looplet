# QA Module — Client & UI

Bu modül yalnız `QA Modules` içinde `client-ui` seçiliyse okunur.

## Required inputs

* `features/{feature-name}/frontend.md` veya ilgili client delivery artifact'ı
* mevcutsa `features/{feature-name}/ui-design.md`
* route/navigation/state contract'ı için `architecture.md`
* gerekirse `project-authority/platform.md`

Visual premium puanlama bu modülün görevi değildir; `Visual Scope != none` ise ayrıca `visual-quality` modülü gerekir.

## Required checks

Canonical runtime target üzerinde uygulanabilir olanları doğrula:

* screen goal ve critical user journey
* route, header, back, dismiss ve deep-link davranışı
* loading/error/empty/success/disabled/selected/focused state'leri
* validation feedback ve duplicate action koruması
* API → view-model/store → görünür UI mapping
* retry/back/cancel ve invalid direct entry
* accessibility/ergonomi için feature'da tanımlı requirement'lar
* `ui-design.md` varsa CTA hierarchy, component/state handoff ve interaction intent

Sibling screen veya shared chrome parity isteniyorsa repository'deki gerçek çalışan sibling screen ground truth'tur. Yalnız component adı eşleşmesi görsel/davranışsal parity kanıtı değildir.

Source inspection yardımcı kanıttır; kullanıcıya görünen journey için runtime capture/action sonucu gerekir. Simulator/device açılamıyorsa required scenario pending kalır.

## Output — Client & UI Compliance

Exact başlık:

```text
## Client & UI Compliance
```

Kısa tabloyla journey/state/navigation/handoff kontrollerini ve evidence ID'lerini yaz. UI finding varsa core `Findings` bölümünde ayrı kayıt aç.
