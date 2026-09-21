#!/usr/bin/env python3

import re
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request
import zipfile
from pathlib import Path


ORG = "oncparkdreef"
SCHOOL_YEAR = "2627"

SLUG_PATTERN = re.compile(
    r"^m(\d+)-w(\d{2})$"
)


def fail(message):
    print(message)
    raise SystemExit(1)


def get_login():
    result = subprocess.run(
        [
            "gh",
            "api",
            "user",
            "--jq",
            ".login",
        ],
        text=True,
        capture_output=True,
    )

    if result.returncode != 0:
        fail(
            "GitHub-account kon niet worden bepaald."
        )

    login = result.stdout.strip()

    if not login:
        fail(
            "GitHub-account kon niet worden bepaald."
        )

    return login


def target_is_empty(path):
    if not path.exists():
        return True

    return not any(
        path.iterdir()
    )


def validate_archive(archive):
    for info in archive.infolist():
        member = Path(info.filename)

        if member.is_absolute():
            fail(
                "Download bevat een ongeldig pad."
            )

        if ".." in member.parts:
            fail(
                "Download bevat een ongeldig pad."
            )


def main():
    if len(sys.argv) != 2:
        fail(
            "Gebruik: get m1-w01"
        )

    slug = sys.argv[1].strip().lower()

    match = SLUG_PATTERN.fullmatch(
        slug
    )

    if not match:
        fail(
            "Gebruik: get m1-w01"
        )

    module_number = int(
        match.group(1)
    )

    week = match.group(2)

    login = get_login()

    student_repo = (
        Path("/workspaces")
        / f"informatica-{SCHOOL_YEAR}-{login}"
    )

    if not (
        student_repo / ".git"
    ).is_dir():
        fail(
            "Leerlingrepo is niet gevonden."
        )

    target = (
        student_repo
        / f"module{module_number}"
        / f"week{week}"
    )

    if not target_is_empty(target):
        fail(
            f"Niet opgehaald: "
            f"module{module_number}/week{week} "
            "bevat al bestanden."
        )

    url = (
        f"https://{ORG}.github.io/"
        f"informatica-{SCHOOL_YEAR}/"
        f"module{module_number:02d}/"
        f"downloads/{slug}.zip"
    )

    with tempfile.TemporaryDirectory(
        prefix="onc-get-"
    ) as temp_directory:

        zip_path = (
            Path(temp_directory)
            / f"{slug}.zip"
        )

        try:
            urllib.request.urlretrieve(
                url,
                zip_path,
            )

        except urllib.error.HTTPError as error:
            if error.code == 404:
                fail(
                    f"Week {slug} is nog niet beschikbaar."
                )

            fail(
                f"Download mislukt "
                f"(HTTP {error.code})."
            )

        except urllib.error.URLError:
            fail(
                "Download mislukt. "
                "Controleer je internetverbinding."
            )

        try:
            with zipfile.ZipFile(
                zip_path,
                "r",
            ) as archive:

                validate_archive(
                    archive
                )

                files = [
                    info
                    for info in archive.infolist()
                    if not info.is_dir()
                ]

                if not files:
                    fail(
                        f"Week {slug} bevat geen bestanden."
                    )

                target.mkdir(
                    parents=True,
                    exist_ok=True,
                )

                archive.extractall(
                    target
                )

        except zipfile.BadZipFile:
            fail(
                "Het gedownloade bestand is geen geldige ZIP."
            )

    print(
        f"{slug} opgehaald naar "
        f"module{module_number}/week{week}"
    )


if __name__ == "__main__":
    main()
