import Pkg
file1 = "datasets/mHealth_subject1.log"
file2 = "datasets/mHealth_subject2.log"
file3 = "datasets/mHealth_subject3.log"
file4 = "datasets/mHealth_subject4.log"
file5 = "datasets/mHealth_subject5.log"
file6 = "datasets/mHealth_subject6.log"
file7 = "datasets/mHealth_subject7.log"
file8 = "datasets/mHealth_subject8.log"
file9 = "datasets/mHealth_subject9.log"
file10 = "datasets/mHealth_subject10.log"

function loadData()
    file = open(file1, "r")
    lines = readlines(file)
    rows = length(lines)
    data = Array{Float64, 2}(undef, rows, 23)
    for i in range(1, rows)
        row = split(lines[i], "\t")
        for j in range(1, 23)
            data[i, j] = parse(Float64, row[j])
        end
    end
    data = transpose(data)
    return data
end

