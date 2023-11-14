import subprocess

def convert_with_pandoc(input_file, output_file):
    # Conversione in formato markdown
    markdown_output = output_file.replace('.pdf', '.md')
    markdown_command = [
        'pandoc',
        input_file,
        '-o',
        markdown_output,
        '--toc',
        '-s'
    ]

    # Conversione in formato PDF
    pdf_output = output_file
    pdf_command = [
        'pandoc',
        markdown_output,
        '-o',
        pdf_output
    ]

    try:
        # Conversione in markdown
        subprocess.run(markdown_command, check=True)
        print(f"Conversione in markdown completata: '{input_file}' -> '{markdown_output}'.")

        # Conversione in PDF
        subprocess.run(pdf_command, check=True)
        print(f"Conversione in PDF completata: '{markdown_output}' -> '{pdf_output}'.")
    except subprocess.CalledProcessError as e:
        print(f"Si è verificato un errore durante la conversione: {e}")

# Utilizzo della funzione
input_file = 'Sistemi Operativi Avanzati.md'
output_file = 'output.pdf'
convert_with_pandoc(input_file, output_file)

