"""Convertit les catalogues Excel (docs/catalogues) en assets/data/parcours.json.

Usage : python3 tool/convert_catalogues.py
Relancer après chaque révision des catalogues par l'expert-comptable.
"""
import json
import re
from pathlib import Path

import openpyxl

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "docs" / "catalogues"

PARCOURS = [
    ("SU", "SUARL", "Société unipersonnelle à responsabilité limitée", "Catalogue_taches_SUARL.xlsx", "Tâches SUARL"),
    ("SA", "SARL", "Société à responsabilité limitée", "Catalogue_taches_autres_parcours.xlsx", "SARL"),
    ("EI", "Entreprise individuelle", "Personne physique, sans capital", "Catalogue_taches_autres_parcours.xlsx", "Entreprise individuelle"),
    ("AE", "Auto-entrepreneur", "Statut simplifié, chiffre d'affaires jusqu'à 75 000 DT", "Catalogue_taches_autres_parcours.xlsx", "Auto-entrepreneur"),
    ("EC", "Entreprise communautaire", "Projet collectif local ou régional", "Catalogue_taches_autres_parcours.xlsx", "Entreprise communautaire"),
]

# Conditions du catalogue (texte lisible) -> règle lisible par l'application.
# Une règle : null (toujours), {"q","eq"}, {"q","ne"}, {"q","in"}, {"any":[...]}, {"all":[...]}
CONDITIONS = {
    "Toujours": None,
    "Q14 = Non": {"q": "Q14", "eq": "non"},
    "Q10 ≠ Non": {"q": "Q10", "ne": "non"},
    "Q11 ≠ Non": {"q": "Q11", "ne": "non"},
    "Q15 ≠ Déjà créé": {"q": "Q15", "ne": "cree"},
    "Q15 = Idée": {"q": "Q15", "eq": "idee"},
    "Q8 = Oui, à louer": {"q": "Q8", "eq": "a_louer"},
    "Q3 = activité réglementée": {"q": "Q3", "in": ["oui", "nsp"]},
    "Q9 = Oui": {"q": "Q9", "eq": "oui"},
    "Q12 = Oui": {"q": "Q12", "eq": "oui"},
    "Q8 ≠ Non, domicile OU Q9 = Oui": {"any": [{"q": "Q8", "ne": "domicile"}, {"q": "Q9", "eq": "oui"}]},
    # Conditions sans question dédiée dans la version 0 : tâche toujours affichée,
    # l'utilisateur peut la marquer « Non concernée ».
    "Q1 = Tunisien résident ET Q4 = Seul ET Q5 < 75 000 DT": None,
    "CA cumulé > 60 000 DT": None,
    "Gérant non nommé dans les statuts": None,
    "Parcours = Entreprise communautaire": None,
}


def offset_days(rappel: str):
    m = re.match(r"^J\+(\d+)", rappel or "")
    return int(m.group(1)) if m else None


def split_list(value: str):
    if not value or value.strip() in ("—", "-"):
        return []
    return [p.strip() for p in value.split("·") if p.strip()]


def main():
    out = []
    for code, name, subtitle, fname, sheet in PARCOURS:
        ws = openpyxl.load_workbook(SRC / fname)[sheet]
        tasks = []
        for r in ws.iter_rows(min_row=2, values_only=True):
            if not r[0]:
                continue
            cond = r[11]
            if cond not in CONDITIONS:
                raise SystemExit(f"Condition inconnue pour {r[0]} : {cond!r} — ajoutez-la dans CONDITIONS")
            deps = [] if r[10] in (None, "—") else [d.strip() for d in str(r[10]).split(",")]
            tasks.append({
                "id": r[0],
                "phase": r[1],
                "title": r[2],
                "explanation": r[3],
                "why": r[4],
                "organisme": r[5],
                "demarche": r[6],
                "documents": split_list(r[7]),
                "cost": str(r[8]),
                "delay": str(r[9]),
                "dependsOn": deps,
                "condition": CONDITIONS[cond],
                "reminderText": r[12],
                "offsetDays": offset_days(r[12]),
                "toVerify": r[13] == "À vérifier",
            })
        ids = {t["id"] for t in tasks}
        for t in tasks:
            for d in t["dependsOn"]:
                if d not in ids:
                    raise SystemExit(f"{t['id']} dépend de {d}, absent du parcours {code}")
        out.append({"code": code, "name": name, "subtitle": subtitle, "tasks": tasks})
    dest = ROOT / "assets" / "data" / "parcours.json"
    dest.write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")
    print({p["code"]: len(p["tasks"]) for p in out}, "→", dest.relative_to(ROOT))


if __name__ == "__main__":
    main()
