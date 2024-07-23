using System.ComponentModel.DataAnnotations;

public class Category
{
    public Guid Id { get; set; }

    public Guid? ParentId { get; set; }
    public required string CategoryName { get; set; }
    public required List<Colloquial> Colloquial { get; set; }
    public required List<Question> Questions { get; set; }
}

public class Colloquial
{
    [Key]
    public required string Key { get; set; }
    public required string Content { get; set; }
}

public class Question
{
    [Key]
    public required string Key { get; set; }
    public required string Content { get; set; }
}