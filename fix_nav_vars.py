with open('lib/nav.dart', 'r') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "static GoRouter createRouter(AppAuthProvider authProvider) {" in line:
        # Define the variables right at the start of the function
        injection = [
            "    final launchEnabled = authProvider.launchEnabled;\n",
            "    const fallback = '/';\n"
        ]
        lines.insert(i + 1, injection[0])
        lines.insert(i + 2, injection[1])
        print("Successfully injected launchEnabled and fallback variables into createRouter!")
        break

with open('lib/nav.dart', 'w') as f:
    f.writelines(lines)
