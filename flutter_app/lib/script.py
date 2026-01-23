import os

def generate_structure(path, prefix=""):
    entries = [e for e in os.listdir(path) if not e.startswith(".")]
    entries.sort()

    lines = []

    for index, entry in enumerate(entries):
        full_path = os.path.join(path, entry)
        is_last = index == len(entries) - 1

        connector = "|___ "
        line = f"{prefix}{connector}{entry}"
        lines.append(line)

        if os.path.isdir(full_path):
            extension = "     " if is_last else "|    "
            lines.extend(generate_structure(full_path, prefix + extension))

    return lines


def save_project_structure(root_dir, output_file="project_structure.txt"):
    lines = [os.path.basename(root_dir)]
    lines.append("|")
    lines.extend(generate_structure(root_dir))

    with open(output_file, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"Project structure saved to {output_file}")


# 🔧 CHANGE THIS
ROOT_DIRECTORY = "./"

save_project_structure(ROOT_DIRECTORY)
